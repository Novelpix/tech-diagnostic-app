/**
 * Module de récupération et structuration des données pour l'audit
 * Attaché à window.AuditPDF pour compatibilité file://
 */

window.AuditPDF = window.AuditPDF || {};

window.AuditPDF.fetchAuditData = async function () {
  const supabase = window.supabaseClient;
  if (!supabase) {
    throw new Error("Client Supabase non initialisé");
  }

  console.log("🔄 Récupération des données d'audit...");

  // 1. Récupérer tous les équipements
  const { data: equipements, error: eqError } = await supabase
    .from('equipements')
    .select('*')
    .order('lot', { ascending: true });

  if (eqError) {
    console.error("❌ Erreur fetch équipements:", eqError);
    throw eqError;
  }

  // 2. Récupérer toutes les photos
  const { data: photos, error: phError } = await supabase
    .from('photos')
    .select('*');

  if (phError) {
    console.error("❌ Erreur fetch photos:", phError);
    throw phError;
  }

  console.log(`✅ Données récupérées: ${equipements.length} équipements, ${photos.length} photos`);

  return { equipements, photos };
};

window.AuditPDF.buildAuditReport = function (rawData) {
  const { equipements, photos } = rawData;
  const timestamp = new Date().toLocaleString('fr-FR');

  // Organiser les photos par equipement_id
  const photosMap = {};
  photos.forEach(p => {
    if (!photosMap[p.equipement_id]) {
      photosMap[p.equipement_id] = [];
    }
    photosMap[p.equipement_id].push(p);
  });

  // Groupes et calculs
  const lots = {};
  const anomalies = [];
  const recommandations = [];

  equipements.forEach(eq => {
    // Groupement par lot
    const lotName = eq.lot || 'Autre';
    if (!lots[lotName]) {
      lots[lotName] = [];
    }
    lots[lotName].push(eq);

    // Anomalies (critique ou urgent)
    const crit = eq.crit || eq.criticite;
    if (crit === 'U' || crit === 'I') {
      anomalies.push(eq);
    }

    // Recommandations
    if (eq.actions || eq.remarques) {
      recommandations.push({
        equipement: eq.code || eq.id,
        lot: lotName,
        action: eq.actions || eq.remarques,
        priorite: eq.priorite || 'N/A'
      });
    }
  });

  // Résumé global
  const resumeGlobal = {
    totalEquipements: equipements.length,
    totalPhotos: photos.length,
    totalAnomalies: anomalies.length,
    lotsCount: Object.keys(lots).length,
    dateExport: timestamp
  };

  return {
    resumeGlobal,
    lots,
    equipements,
    anomalies,
    photosParEquipement: photosMap,
    recommandations,
    horodatage: timestamp
  };
};
