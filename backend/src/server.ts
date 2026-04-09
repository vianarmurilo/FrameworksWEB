import { app } from "./app";
import { env } from "./config/env";

app.listen(env.PORT, () => {
  console.log(`FinMind AI+ API rodando na porta ${env.PORT}`);
});
