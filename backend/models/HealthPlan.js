const mongoose = require('mongoose');

const healthPlanSchema = new mongoose.Schema({
  residentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Resident',
    required: true
  },
  date: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['Active', 'Critical'],
    default: 'Active'
  },
  allergies: String,
  medicalCondition: String,
  medications: String,
  dosage: String,
  quantity: String,
  medicationTime: String,
  isMedicationTaken: {
    type: Boolean,
    default: false
  },
  assessment: String,
  instructions: String
}, {
    timestamps: true,
    collection: 'healthrecords' // Explicitly set the collection name
  });

const HealthPlan = mongoose.model('HealthPlan', healthPlanSchema);
module.exports = HealthPlan;