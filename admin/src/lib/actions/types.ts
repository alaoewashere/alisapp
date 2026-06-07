/** Standard return shape for server actions consumed by client dialogs. */
export type ActionResult = { ok: true } | { ok: false; error: string };

export const actionOk: ActionResult = { ok: true };
export function actionError(error: string): ActionResult {
  return { ok: false, error };
}
