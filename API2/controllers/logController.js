const { getLogModel } = require("../models/LogModel");

// @desc    Get all Logs (with optional status filtering)
// @route   GET /api/logs
// @access  Public
exports.getAllLogs = async (req, res) => {
  try {
    const { appId, status, page = 1, limit = 50 } = req.query;
    
    if (!appId) {
      return res.status(400).json({
        success: false,
        message: "Please provide appId in query parameters",
      });
    }

    const Log = getLogModel(appId);
    
    const filter = { appId };
    if (status) filter.status = status;

    const pageNum = parseInt(page, 10) || 1;
    const limitNum = parseInt(limit, 10) || 50;
    const skip = (pageNum - 1) * limitNum;

    const total = await Log.countDocuments(filter);
    const logs = await Log.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limitNum);

    res.status(200).json({
      success: true,
      count: logs.length,
      total,
      totalPages: Math.ceil(total / limitNum),
      currentPage: pageNum,
      data: logs,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
