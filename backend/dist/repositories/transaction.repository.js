"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TransactionRepository = void 0;
const client_1 = require("@prisma/client");
const prisma_1 = require("../config/prisma");
class TransactionRepository {
    async create(input) {
        return prisma_1.prisma.transaction.create({
            data: {
                userId: input.userId,
                categoryId: input.categoryId,
                familyGroupId: input.familyGroupId,
                type: input.type,
                amount: new client_1.Prisma.Decimal(input.amount),
                description: input.description,
                occurredAt: input.occurredAt,
                paymentMethod: input.paymentMethod,
                isRecurring: input.isRecurring ?? false,
                merchant: input.merchant,
                tags: input.tags ?? [],
            },
            include: {
                category: true,
            },
        });
    }
    async findById(transactionId, userId) {
        return prisma_1.prisma.transaction.findFirst({
            where: {
                id: transactionId,
                userId,
            },
            include: {
                category: true,
            },
        });
    }
    async list(filters) {
        return prisma_1.prisma.transaction.findMany({
            where: {
                userId: filters.userId,
                categoryId: filters.categoryId,
                type: filters.type,
                occurredAt: {
                    gte: filters.startDate,
                    lte: filters.endDate,
                },
            },
            include: {
                category: true,
            },
            orderBy: {
                occurredAt: "desc",
            },
        });
    }
    async update(transactionId, userId, input) {
        const transaction = await prisma_1.prisma.transaction.findFirst({
            where: { id: transactionId, userId },
            select: { id: true },
        });
        if (!transaction) {
            return null;
        }
        return prisma_1.prisma.transaction.update({
            where: { id: transactionId },
            data: {
                categoryId: input.categoryId,
                familyGroupId: input.familyGroupId,
                type: input.type,
                amount: input.amount !== undefined ? new client_1.Prisma.Decimal(input.amount) : undefined,
                description: input.description,
                occurredAt: input.occurredAt,
                paymentMethod: input.paymentMethod,
                isRecurring: input.isRecurring,
                merchant: input.merchant,
                tags: input.tags,
            },
            include: {
                category: true,
            },
        });
    }
    async delete(transactionId, userId) {
        const transaction = await prisma_1.prisma.transaction.findFirst({
            where: { id: transactionId, userId },
            select: { id: true },
        });
        if (!transaction) {
            return false;
        }
        await prisma_1.prisma.transaction.delete({ where: { id: transactionId } });
        return true;
    }
}
exports.TransactionRepository = TransactionRepository;
