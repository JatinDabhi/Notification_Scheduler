const { getTitleModel } = require("../models/titleModel");
const { sendFirebaseNotification } = require("../services/schedulerService");
const { getLogModel } = require("../models/LogModel");

// @desc    Create a new Title and Description (Immediate, Scheduled or Bulk)
// @route   POST /api/titles
// @access  Public
exports.createTitle = async (req, res) => {
  try {
    const { appId, title, description, scheduledAt, callbackUrl, titles } = req.body;

    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId" });
    }
    
    const Title = getTitleModel(appId);

    // Bulk Insertion Mode
    if (titles && Array.isArray(titles) && titles.length > 0) {
      const documents = titles.map((item) => ({
        appId,
        title: item.title,
        description: item.description,
        status: "immediate",
        callbackUrl: item.callbackUrl || null,
      }));

      const newTitles = await Title.insertMany(documents);
      
      return res.status(201).json({
        success: true,
        message: `${newTitles.length} titles stored successfully`,
        data: newTitles,
      });
    }

    // Single Insertion Mode
    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: "Please provide title and description for single insertion, or 'titles' array for bulk",
      });
    }

    let parsedScheduledAt = null;
    let initialStatus = "immediate";

    if (scheduledAt) {
      parsedScheduledAt = new Date(scheduledAt);
      if (isNaN(parsedScheduledAt.getTime())) {
        return res.status(400).json({
          success: false,
          message: "Invalid date format for scheduledAt. Use ISO date string (e.g. YYYY-MM-DDTHH:mm:ssZ)",
        });
      }
      initialStatus = "pending";
    }

    const newTitle = await Title.create({
      appId,
      title,
      description,
      scheduledAt: parsedScheduledAt,
      status: initialStatus,
      callbackUrl: callbackUrl || null,
    });

    res.status(201).json({
      success: true,
      message: parsedScheduledAt
        ? `Title scheduled successfully for ${parsedScheduledAt.toISOString()}`
        : "Title and description stored successfully",
      data: newTitle,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Get all Titles (with optional status filtering)
// @route   GET /api/titles
// @access  Public
exports.getAllTitles = async (req, res) => {
  try {
    const { appId, status, page = 1, limit = 10 } = req.query;
    
    if (!appId) {
      return res.status(400).json({
        success: false,
        message: "Please provide appId in query parameters",
      });
    }

    const Title = getTitleModel(appId);
    
    // We don't strictly need { appId } in the filter since the collection is specific to the appId
    // But keeping it ensures data consistency if something was inserted wrongly.
    const filter = { appId };
    if (status) filter.status = status;

    const pageNum = parseInt(page, 10) || 1;
    const limitNum = parseInt(limit, 10) || 10;
    const skip = (pageNum - 1) * limitNum;

    const total = await Title.countDocuments(filter);
    const titles = await Title.find(filter)
      .sort({ createdAt: 1 })
      .skip(skip)
      .limit(limitNum);

    res.status(200).json({
      success: true,
      count: titles.length,
      total,
      totalPages: Math.ceil(total / limitNum),
      currentPage: pageNum,
      data: titles,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Get single Title by ID
// @route   GET /api/titles/:id
// @access  Public
exports.getTitleById = async (req, res) => {
  try {
    const { appId } = req.query;
    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId in query" });
    }
    
    const Title = getTitleModel(appId);
    const title = await Title.findById(req.params.id);

    if (!title) {
      return res.status(404).json({
        success: false,
        message: "Title entry not found",
      });
    }

    res.status(200).json({
      success: true,
      data: title,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Update Title by ID
// @route   PUT /api/titles/:id
// @access  Public
exports.updateTitle = async (req, res) => {
  try {
    const { appId } = req.query;
    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId in query" });
    }
    
    const Title = getTitleModel(appId);
    
    const { title, description, isActive, scheduledAt, callbackUrl } = req.body;

    const existingTitle = await Title.findById(req.params.id);
    if (!existingTitle) {
      return res.status(404).json({
        success: false,
        message: "Title entry not found",
      });
    }

    if (title) existingTitle.title = title;
    if (description) existingTitle.description = description;
    if (typeof isActive === "boolean") existingTitle.isActive = isActive;
    if (callbackUrl !== undefined) existingTitle.callbackUrl = callbackUrl;

    if (scheduledAt) {
      const parsedDate = new Date(scheduledAt);
      if (!isNaN(parsedDate.getTime())) {
        existingTitle.scheduledAt = parsedDate;
        existingTitle.status = "pending";
      }
    }

    const updatedTitle = await existingTitle.save();

    res.status(200).json({
      success: true,
      message: "Title updated successfully",
      data: updatedTitle,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Delete Title by ID
// @route   DELETE /api/titles/:id
// @access  Public
exports.deleteTitle = async (req, res) => {
  try {
    const { appId } = req.query;
    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId in query" });
    }
    
    const Title = getTitleModel(appId);
    
    const deletedTitle = await Title.findByIdAndDelete(req.params.id);

    if (!deletedTitle) {
      return res.status(404).json({
        success: false,
        message: "Title entry not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Title entry deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Instantly trigger an ad-hoc title (e.g. New Update)
// @route   POST /api/trigger-instant
// @access  Public
exports.triggerInstant = async (req, res) => {
  try {
    const { appId, title, description } = req.body;
    if (!appId || !title || !description) {
      return res.status(400).json({ success: false, message: "Please provide appId, title, and description" });
    }

    const Log = getLogModel(appId);
    const result = await sendFirebaseNotification(appId, title, description);
    
    if (!result.success) {
      await Log.create({
        appId, actionType: "instant", status: "failed", 
        reason: result.error || "Unknown Firebase error", title, description
      });
      return res.status(500).json({ success: false, message: "Failed to send notification via Firebase" });
    }

    await Log.create({
      appId, actionType: "instant", status: "success", 
      reason: "Notification sent successfully.", title, description
    });

    res.status(200).json({
      success: true,
      message: "Instant notification sent successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Trigger an existing Title by ID
// @route   POST /api/titles/:id/trigger
// @access  Public
exports.triggerTitleId = async (req, res) => {
  try {
    const { appId } = req.query;
    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId in query" });
    }
    
    const Title = getTitleModel(appId);
    
    const titleDoc = await Title.findById(req.params.id);
    if (!titleDoc) {
      return res.status(404).json({ success: false, message: "Title not found" });
    }

    const Log = getLogModel(appId);
    const result = await sendFirebaseNotification(appId, titleDoc.title, titleDoc.description);
    
    if (!result.success) {
      await Log.create({
        appId, actionType: "instant", status: "failed", 
        reason: result.error || "Unknown Firebase error", title: titleDoc.title, description: titleDoc.description
      });
      return res.status(500).json({ success: false, message: "Failed to send notification via Firebase" });
    }

    await Log.create({
      appId, actionType: "instant", status: "success", 
      reason: "Notification sent successfully.", title: titleDoc.title, description: titleDoc.description
    });

    // Auto-delete after instant trigger
    await Title.findByIdAndDelete(titleDoc._id);

    res.status(200).json({
      success: true,
      message: "Notification sent successfully",
      data: titleDoc,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
