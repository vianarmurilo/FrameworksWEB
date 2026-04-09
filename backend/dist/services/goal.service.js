"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GoalService = void 0;
const client_1 = require("@prisma/client");
const zod_1 = require("zod");
const app_error_1 = require("../utils/app-error");
const createGoalSchema = zod_1.z.object({
    title: zod_1.z.string().min(2).max(140),
    description: zod_1.z.string().max(400).optional(),
    targetAmount: zod_1.z.number().positive(),
    currentAmount: zod_1.z.number().min(0).optional(),
    deadline: zod_1.z.coerce.date().optional(),
});
const updateGoalSchema = zod_1.z
    .object({
    title: zod_1.z.string().min(2).max(140).optional(),
    description: zod_1.z.string().max(400).optional(),
    targetAmount: zod_1.z.number().positive().optional(),
    currentAmount: zod_1.z.number().min(0).optional(),
    deadline: zod_1.z.coerce.date().optional(),
    status: zod_1.z.enum(client_1.GoalStatus).optional(),
})
    .refine((data) => Object.keys(data).length > 0, "Informe ao menos um campo");
class GoalService {
    constructor(goalRepository) {
        this.goalRepository = goalRepository;
    }
    async create(userId, rawInput) {
        const input = createGoalSchema.parse(rawInput);
        return this.goalRepository.create({ userId, ...input });
    }
    async list(userId) {
        const goals = await this.goalRepository.listByUser(userId);
        return goals.map((goal) => ({
            ...goal,
            progress: Number(goal.currentAmount) / Number(goal.targetAmount),
        }));
    }
    async update(userId, goalId, rawInput) {
        const input = updateGoalSchema.parse(rawInput);
        if (input.targetAmount !== undefined && input.currentAmount !== undefined && input.currentAmount > input.targetAmount) {
            input.status = "ACHIEVED";
        }
        const updated = await this.goalRepository.update(userId, goalId, input);
        if (!updated) {
            throw new app_error_1.AppError("Meta nao encontrada", 404);
        }
        return updated;
    }
    async delete(userId, goalId) {
        const removed = await this.goalRepository.delete(userId, goalId);
        if (!removed) {
            throw new app_error_1.AppError("Meta nao encontrada", 404);
        }
    }
}
exports.GoalService = GoalService;
