const express = require("express");
const {
  createTitle,
  getAllTitles,
  getTitleById,
  updateTitle,
  deleteTitle,
  triggerInstant,
  triggerTitleId,
} = require("../controllers/titleController");

const router = express.Router();

router.post("/trigger-instant", triggerInstant);

router.route("/")
  .get(getAllTitles)
  .post(createTitle);

router.post("/:id/trigger", triggerTitleId);

router.route("/:id")
  .get(getTitleById)
  .put(updateTitle)
  .delete(deleteTitle);

module.exports = router;
