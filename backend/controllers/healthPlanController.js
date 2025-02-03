const mongoose = require('mongoose');
const HealthPlan = require('../models/HealthPlan');

const healthPlanController = {
  // Get health plan by resident ID
  getHealthPlan: async (req, res) => {
    try {
      console.log('Looking for health plan with residentId:', req.params.residentId);
      
      const healthPlan = await HealthPlan.findOne({
        residentId: new mongoose.Types.ObjectId(req.params.residentId)
      }).sort({ createdAt: -1 });
      
      if (!healthPlan) {
        console.log('No health plan found for resident');
        return res.status(404).json({ message: 'Health plan not found' });
      }
      
      console.log('Found health plan:', healthPlan);
      res.json(healthPlan);
    } catch (error) {
      console.error('Error in getHealthPlan:', error);
      res.status(500).json({ message: error.message });
    }
  },

  // Get health plan by ID
  getHealthPlanById: async (req, res) => {
    try {
      const healthPlan = await HealthPlan.findById(req.params.id);
      
      if (!healthPlan) {
        return res.status(404).json({ message: 'Health plan not found' });
      }
      
      res.json(healthPlan);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },

  // Create new health plan
  createHealthPlan: async (req, res) => {
    try {
      const healthPlan = new HealthPlan({
        residentId: new mongoose.Types.ObjectId(req.body.residentId),
        date: req.body.date,
        status: req.body.status,
        allergies: req.body.allergies,
        medicalCondition: req.body.medicalCondition,
        medications: req.body.medications,
        dosage: req.body.dosage,
        quantity: req.body.quantity,
        medicationTime: req.body.medicationTime,
        isMedicationTaken: req.body.isMedicationTaken,
        assessment: req.body.assessment,
        instructions: req.body.instructions
      });

      const newHealthPlan = await healthPlan.save();
      res.status(201).json(newHealthPlan);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  },

  // Update health plan
  updateHealthPlan: async (req, res) => {
    try {
      const healthPlan = await HealthPlan.findById(req.params.id);
      
      if (!healthPlan) {
        return res.status(404).json({ message: 'Health plan not found' });
      }

      Object.assign(healthPlan, req.body);
      const updatedHealthPlan = await healthPlan.save();
      res.json(updatedHealthPlan);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  }
};

module.exports = healthPlanController;