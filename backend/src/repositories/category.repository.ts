import { prisma } from "../config/prisma";

export class CategoryRepository {
  async findById(categoryId: string) {
    return prisma.category.findUnique({ where: { id: categoryId } });
  }
}
