const mongoose = require("mongoose");

const healthPlanSchema = new mongoose.Schema(
  {
    residentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Resident",
      required: true,
    },
    date: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ["Critical", "Stable"],
      default: "Stable",
    },
    allergies: [
      {
        type: String,
        trim: true,
      },
    ],
    medicalCondition: [
      {
        type: String,
        trim: true,
      },
    ],
    medications: [
      {
        medication: String,
        dosage: String,
        quantity: String,
        time: [String],
        status: {
          type: String,
          enum: ["Taken", "Not taken"],
          default: "Not taken",
        },
      },
    ],
    assessment: String,
    instructions: String,
  },
  {
    timestamps: true,
    collection: "healthrecords",
  }
);

const HealthPlan = mongoose.model("HealthPlan", healthPlanSchema);
module.exports = HealthPlan;
