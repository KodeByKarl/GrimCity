/** Shared NUI fetch with browser mocks for module control pages. */

export function isBrowserEnv() {
  return (
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM")
  );
}

export async function fetchNui<T = unknown>(eventName: string, data?: unknown): Promise<T> {
  if (isBrowserEnv()) {
    if (eventName === "cfx-keydi-modules:getPatchNotes") {
      return {
        updates: [
          {
            version: "2.4.0",
            date: "2026-09-05",
            title: "Autofarm + iPad Apps",
            tag: "UPDATE",
            notes: [
              "New Grim City autofarm HUD with bag-full ETA",
              "iPad Economy / PD Boss / Party preview apps",
              "Playtime shop Grim Coins rewards",
            ],
          },
          {
            version: "2.3.1",
            date: "2026-08-20",
            title: "Regions Control Center",
            tag: "FEATURE",
            notes: ["Farm / School / Turf region switching", "Orange job instance"],
          },
        ],
      } as T;
    }
    if (eventName === "cfx-keydi-modules:getJobs") {
      return {
        jobs: [
          { job: "police", grade: 3, label: "Police", grade_label: "Sergeant", is_active: 1 },
          { job: "ambulance", grade: 1, label: "EMS", grade_label: "EMT", is_active: 0 },
          { job: "mechanic", grade: 0, label: "Mechanic", grade_label: "Trainee", is_active: 0 },
        ],
        activeJob: "police",
        isOnDuty: true,
      } as T;
    }
    if (eventName === "cfx-keydi-modules:getServers") {
      return {
        publicServers: undefined,
        sideJobServers: undefined,
        inSafezone: true,
        isLocked: false,
        lockReason: null,
      } as T;
    }
    if (eventName === "cfx-keydi-modules:getRockstarState") {
      return { recording: false } as T;
    }
    if (eventName === "cfx-keydi-modules:rockstarAction") {
      const button = (data as { button?: string } | undefined)?.button;
      if (button === "record") return { ok: true, recording: true } as T;
      if (button === "save" || button === "delete") return { ok: true, recording: false } as T;
      return { ok: true, recording: false } as T;
    }
    if (eventName === "cfx-keydi-modules:toggleJobDuty") {
      return { ok: true } as T;
    }
    if (eventName === "cfx-keydi-modules:connectServer") {
      return { ok: true } as T;
    }
    if (eventName === "cfx-keydi-vip:getStatus") {
      return {
        vip: {
          active: true,
          tier: "vip3",
          label: "VIP 3",
          daysRemaining: 12,
          hoursRemaining: 8,
          renewsAt: "2026-09-17T18:00:00Z",
          expiresAt: "2026-09-17T18:00:00Z",
          autoRenew: true,
          pedMenu: true,
          welcomeBanner: true,
          perks: [
            "Priority queue",
            "Ped Menu (/pedmenu)",
            "3 character slots (MultiVIP)",
            "Edit own welcome banner",
            "VIP chat tag",
          ],
          characterSlots: 3,
        },
      } as T;
    }
    if (eventName === "cfx-keydi-vip:openPedMenu" || eventName === "cfx-keydi-vip:openWelcomeBanner") {
      return { ok: true } as T;
    }
    return {} as T;
  }

  const resourceName = (window as unknown as { GetParentResourceName?: () => string })
    .GetParentResourceName
    ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
    : "kodebykarl-ui";

  const resp = await fetch(`https://${resourceName}/${eventName}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data ?? {}),
  });
  return (await resp.json()) as T;
}
