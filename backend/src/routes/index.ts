import { Router } from "express";
import { healthRouter } from "./health.routes";
import { authRouter } from "./auth.routes";
import { transactionRouter } from "./transaction.routes";
import { goalRouter } from "./goal.routes";
import { categoryRouter } from "./category.routes";
import { subscriptionRouter } from "./subscription.routes";
import { familyRouter } from "./family.routes";
import { intelligenceRouter } from "./intelligence.routes";
import { adminRouter } from "./admin.routes";

export const apiRouter = Router();

apiRouter.use(healthRouter);
apiRouter.use("/auth", authRouter);
apiRouter.use("/transactions", transactionRouter);
apiRouter.use("/goals", goalRouter);
apiRouter.use("/categories", categoryRouter);
apiRouter.use("/subscriptions", subscriptionRouter);
apiRouter.use("/family", familyRouter);
apiRouter.use("/admin", adminRouter);
apiRouter.use(intelligenceRouter);
