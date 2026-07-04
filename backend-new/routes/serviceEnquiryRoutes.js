const express = require("express");
const router = express.Router();
const {
  createEnquiry,
  getAllEnquiries,
  updateStatus,
  deleteEnquiry,
} = require("../controllers/serviceEnquiryController");
const requireCmsAdmin = require("../middleware/requireCmsAdmin");

router.post("/", createEnquiry);
router.get("/admin", requireCmsAdmin, getAllEnquiries);
router.put("/:id/status", requireCmsAdmin, updateStatus);
router.delete("/:id", requireCmsAdmin, deleteEnquiry);

module.exports = router;
