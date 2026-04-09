"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = errorHandler;
const zod_1 = require("zod");
const app_error_1 = require("../utils/app-error");
function errorHandler(error, _req, res, _next) {
    if (error instanceof app_error_1.AppError) {
        res.status(error.statusCode).json({ message: error.message });
        return;
    }
    if (error instanceof zod_1.ZodError) {
        res.status(400).json({ message: "Dados invalidos", issues: error.issues });
        return;
    }
    console.error(error);
    res.status(500).json({ message: "Erro interno no servidor" });
}
