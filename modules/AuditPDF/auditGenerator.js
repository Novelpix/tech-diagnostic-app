
window.AuditPDF = window.AuditPDF || {};

window.AuditPDF.generateAuditPDF = async function (report) {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();

    // Helper for centering text
    const centerText = (text, y, size = 12, style = 'normal') => {
        doc.setFontSize(size);
        doc.setFont('helvetica', style);
        const textWidth = doc.getTextWidth(text);
        doc.text(text, (pageWidth - textWidth) / 2, y);
    };

    // 1. COVER PAGE
    doc.setFillColor(44, 90, 160); // #2c5aa0
    doc.rect(0, 0, pageWidth, pageHeight, 'F');

    doc.setTextColor(255, 255, 255);
    centerText("RAPPORT D'AUDIT TECHNIQUE", 100, 24, 'bold');
    centerText("PEC - LA DÉFENSE", 120, 18);

    centerText(report.horodatage, pageHeight - 30, 12);
    centerText("Delta Optima Control", pageHeight - 20, 10);

    // 2. SUMMARY PAGE
    doc.addPage();
    doc.setTextColor(0, 0, 0);
    centerText("SYNTHÈSE GLOBALE", 20, 18, 'bold');

    let y = 40;
    doc.setFontSize(12);
    doc.text(`Date de l'audit : ${report.horodatage}`, 20, y); y += 10;
    doc.text(`Nombre de lots audités : ${report.resumeGlobal.lotsCount}`, 20, y); y += 10;
    doc.text(`Total équipements : ${report.resumeGlobal.totalEquipements}`, 20, y); y += 10;
    doc.text(`Total photos : ${report.resumeGlobal.totalPhotos}`, 20, y); y += 10;
    doc.text(`Anomalies critiques/importantes : ${report.resumeGlobal.totalAnomalies}`, 20, y); y += 20;

    // 3. LOT PAGES
    for (const [lotName, equipments] of Object.entries(report.lots)) {
        doc.addPage();
        doc.setFillColor(240, 240, 240);
        doc.rect(0, 0, pageWidth, 30, 'F');
        doc.setTextColor(44, 90, 160);
        doc.text(`LOT : ${lotName}`, 20, 20);

        doc.setTextColor(0, 0, 0);
        y = 50;
        doc.text(`Nombre d'équipements : ${equipments.length}`, 20, y);
        y += 20;

        // List equipments briefly
        equipments.forEach(eq => {
            if (y > pageHeight - 20) {
                doc.addPage();
                y = 20;
            }
            const code = eq.code || 'N/A';
            const type = eq.type || 'Inconnu';
            const crit = eq.crit || eq.criticite || '';
            let line = `- ${code} : ${type}`;
            if (crit) line += ` [${crit}]`;
            doc.text(line, 20, y);
            y += 10;
        });
    }

    // 4. EQUIPMENT DETAILS
    for (const eq of report.equipements) {
        doc.addPage();

        // Header
        doc.setFillColor(44, 90, 160);
        doc.rect(0, 0, pageWidth, 20, 'F');
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(14);
        doc.text(`${eq.code || 'Sans Code'} - ${eq.type || 'Type Inconnu'}`, 10, 14);

        // Details
        doc.setTextColor(0, 0, 0);
        doc.setFontSize(10);
        y = 40;

        const leftX = 20;
        const rightX = 110;

        doc.text(`Lot : ${eq.lot || '-'}`, leftX, y);
        doc.text(`Niveau : ${eq.niveau || '-'}`, rightX, y);
        y += 10;
        doc.text(`Local : ${eq.local || '-'}`, leftX, y);
        doc.text(`Marque : ${eq.marque || '-'}`, rightX, y);
        y += 10;
        doc.text(`Modèle : ${eq.modele || '-'}`, leftX, y);
        doc.text(`Série : ${eq.serie || '-'}`, rightX, y);
        y += 10;

        y += 10;
        doc.setFont('helvetica', 'bold');
        doc.text("État & Anomalies", leftX, y);
        doc.setFont('helvetica', 'normal');
        y += 10;
        doc.text(`État (EV) : ${eq.ev || '-'}`, leftX, y);
        doc.text(`Criticité : ${eq.crit || eq.criticite || '-'}`, rightX, y);
        y += 10;
        doc.text(`Constat : ${eq.constat || '-'}`, leftX, y);
        y += 10;
        doc.text(`Actions : ${eq.actions || '-'}`, leftX, y);
        y += 20;

        // Photos
        const photos = report.photosParEquipement[eq.id] || [];
        if (photos.length > 0) {
            doc.setFont('helvetica', 'bold');
            doc.text("Photos", leftX, y);
            y += 10;

            let xPos = leftX;
            for (const photo of photos) {
                if (y > pageHeight - 60) {
                    doc.addPage();
                    y = 20;
                }

                try {
                    // Fetch image to base64
                    const base64 = await urlToBase64(photo.url);
                    if (base64) {
                        // Fit image in 80x80 box
                        doc.addImage(base64, 'JPEG', xPos, y, 80, 60);
                        xPos += 90;
                        if (xPos > pageWidth - 80) {
                            xPos = leftX;
                            y += 70;
                        }
                    }
                } catch (e) {
                    console.error("Error adding image to PDF", e);
                    doc.text("[Erreur chargement photo]", xPos, y + 30);
                }
            }
        }
    }

    doc.save(`Audit_PEC_LaDefense_${new Date().toISOString().slice(0, 10)}.pdf`);
};

async function urlToBase64(url) {
    try {
        const response = await fetch(url);
        const blob = await response.blob();
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    } catch (e) {
        console.warn("Failed to convert image to base64", url, e);
        return null;
    }
}
