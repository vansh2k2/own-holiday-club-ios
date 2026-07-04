const express = require("express");
const router = express.Router();
const {
  submitEnquiry,
  getEnquiries,
  updateStatus,
  deleteEnquiry,
} = require("../controllers/contactEnquiryController");
const requireCmsAdmin = require("../middleware/requireCmsAdmin");

router.post("/", submitEnquiry);

// Admin routes
router.get("/admin", requireCmsAdmin, getEnquiries);
router.put("/:id/status", requireCmsAdmin, updateStatus);
router.delete("/:id", requireCmsAdmin, deleteEnquiry);

module.exports = router;
