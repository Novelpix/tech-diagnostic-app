// Script de conversion du JSON d'import vers le format attendu par l'application
const fs = require('fs');

// Lire le fichier source
const sourceFile = 'import-pec-tech-80-equipements.json';

if (!fs.existsSync(sourceFile)) {
  console.error(`❌ Erreur : Le fichier source "${sourceFile}" est introuvable.`);
  process.exit(1);
}

let sourceData;
try {
  sourceData = JSON.parse(fs.readFileSync(sourceFile, 'utf8'));
} catch (e) {
  console.error('❌ Erreur : Impossible de lire ou parser le fichier JSON source.', e.message);
  process.exit(1);
}

// Fonction pour générer un ID unique
function generateId() {
  return Date.now() + Math.random();
}

// Fonction pour générer un code unique
function generateCode(lot) {
  const prefix = lot.substring(0, 3).toUpperCase();
  const timestamp = Date.now().toString().slice(-6);
  return `${prefix}-${timestamp}-${Math.floor(Math.random() * 1000)}`;
}

// Mapping des noms de champs
const fieldMapping = {
  'localisation': (val) => {
    const parts = val.split(' - ');
    return {
      niveau: parts.length > 1 ? parts[1] : '',
      local: parts[0]
    };
  },
  'equipement': 'type',
  'etatVisuel': 'ev',
  'description': 'constat',
  'criticite': 'crit',
  'typeAnomalie': 'type_anomalie',
  'budget': 'budget'
};

// Convertir les données
const convertedData = {
  equipmentData: {},
  completedLots: [],
  journalVisite: {
    incidents: '',
    zonesNonVisitees: '',
    pointsARevoir: ''
  },
  syntheseTerrain: {
    forces: '',
    faiblesses: '',
    priorites: '',
    recommandations: ''
  },
  formatRestitution: 'csv',
  cloudUrl: '',
  gmaoLogiciel: '',
  googleSheetsUrl: '',
  googleSheetsEnabled: false
};

// Transformer chaque lot
for (const [lotName, equipments] of Object.entries(sourceData)) {
  const normalizedLotName = lotName === 'CVC - Production' ? 'CVC Production' :
    lotName === 'CVC - Distribution' ? 'CVC Distribution' :
      lotName === 'CVC - Émission' ? 'CVC Émission' :
        lotName === 'Électricité CFA/GTB' ? 'GTB' :
          lotName;

  convertedData.equipmentData[normalizedLotName] = equipments.map(eq => {
    const location = fieldMapping.localisation(eq.localisation);

    return {
      id: generateId(),
      lot: normalizedLotName,
      code: generateCode(normalizedLotName),
      date: new Date().toISOString().split('T')[0],
      heureDebut: eq.heureDebut || '',
      heureFin: eq.heureFin || '',
      technicien: '',
      entreprise: eq.entreprise || '',
      contactSite: eq.contactSite || '',
      telReferent: eq.telReferent || '',
      meteo: eq.meteo || '',
      typeVisite: eq.typeVisite || '',
      niveau: location.niveau,
      local: location.local,
      type: eq.equipement,
      qrCode: '',
      refDOE: '',
      refPlan: '',
      marque: '',
      modele: '',
      serie: '',
      puissance: '',
      unite: 'kW',
      annee: '',
      ev: eq.etatVisuel,
      crit: eq.criticite,
      type_anomalie: eq.typeAnomalie,
      budget: eq.budget,
      priorite: calculatePriority(eq.etatVisuel, eq.criticite, eq.budget),
      constat: eq.description,
      observations: '',
      actions: '',
      photos: Array.isArray(eq.photos) ? eq.photos.map(p => ({
        id: generateId(),
        name: p,
        data: '',
        size: 0
      })) : [],
      croquis: eq.croquis || null,
      timestamp: new Date().toISOString()
    };
  });
}

// Fonction de calcul de priorité
function calculatePriority(ev, crit, budget) {
  const critWeight = { U: 10, I: 5, A: 2, S: 1 };
  const budgetWeight = { A: 1, B: 2, C: 5, D: 8, E: 10 };
  return (ev + 1) * (critWeight[crit] || 1) * (budgetWeight[budget] || 1);

}

// Sauvegarder le fichier converti
fs.writeFileSync(
  'import-pec-tech-80-equipements-CONVERTI.json',
  JSON.stringify(convertedData, null, 2),
  'utf8'
);

console.log('✅ Conversion terminée !');
console.log('📁 Fichier créé : import-pec-tech-80-equipements-CONVERTI.json');
console.log(`📊 ${Object.keys(convertedData.equipmentData).length} lots convertis`);
let totalEquipments = 0;
for (const lot in convertedData.equipmentData) {
  totalEquipments += convertedData.equipmentData[lot].length;
}
console.log(`🔧 ${totalEquipments} équipements convertis`);
