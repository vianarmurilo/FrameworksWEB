import { Request, Response } from "express";
import { z } from "zod";
import { AdminService } from "../services/admin.service";

const listUsersQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(10),
  search: z.string().trim().max(120).optional(),
  sortOrder: z.enum(["asc", "desc"]).default("desc"),
});

export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  listUsers = async (req: Request, res: Response): Promise<void> => {
    const query = listUsersQuerySchema.parse(req.query);
    const users = await this.adminService.listUsers(query);

    console.info(
      JSON.stringify({
        event: "admin.users.list",
        actorUserId: req.user?.userId,
        actorEmail: req.user?.email,
        page: query.page,
        pageSize: query.pageSize,
        search: query.search ?? null,
        sortOrder: query.sortOrder,
      }),
    );

    res.status(200).json(users);
  };
}