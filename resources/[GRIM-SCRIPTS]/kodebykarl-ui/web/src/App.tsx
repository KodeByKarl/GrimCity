import { useState, useEffect, lazy, Suspense } from "react";
import Scoreboard from "./cfx-keydi-scoreboard/Scoreboard";
import IndicatorConfig from "./cfx-keydi-indicator/IndicatorConfig";
import DamageOverlay from "./cfx-keydi-indicator/DamageOverlay";
import Chat from "./cfx-keydi-chat/Chat";
import ModulesMenu from "./cfx-keydi-modules/ModulesMenu";
import FpsOptimizer, { FpsPreset } from "./cfx-keydi-fps/FpsOptimizer";
import ReportSystem, { OpenReport, ReportCategory } from "./cfx-keydi-report/ReportSystem";
import BankingSystem from "./cfx-keydi-banking/BankingSystem";
import ImpoundNotification from "./cfx-keydi-impound/ImpoundNotification";
import AutofarmHud from "./cfx-keydi-autofarm/AutofarmHud";
import PatchNotes from "./cfx-keydi-patchnotes/PatchNotes";
import MultiJob from "./cfx-keydi-multijob/MultiJob";
import Regions from "./cfx-keydi-regions/Regions";
import RockstarRecording from "./cfx-keydi-rockstar/RockstarRecording";
import VipStatus from "./cfx-keydi-vip/VipStatus";
import DeathScreen from "./cfx-keydi-deathscreen/DeathScreen";
import { PREVIEW_DEATH, type DeathScreenData } from "./cfx-keydi-deathscreen/types";
import WelcomeBanner from "./welcomebanner/WelcomeBanner";
import WelcomeBannerPanel, { WelcomeBannerPanelData } from "./welcomebanner/WelcomeBannerPanel";
import WelcomeBannerVolume, { WelcomeBannerVolumeData } from "./welcomebanner/WelcomeBannerVolume";
import WelcomeScreen from "./cfx-keydi-welcome/WelcomeScreen";
import Badge, { BadgeData } from "./cfx-keydi-badge/Badge";
import RadioListHud, { RadioPlayer } from "./cfx-keydi-radiolist/RadioListHud";
import RadioListModal from "./cfx-keydi-radiolist/RadioListModal";
import MarketMenu, { MarketData } from "./cfx-keydi-market/MarketMenu";
import FreeCarMenu, { FreeCarData } from "./cfx-keydi-freecar/FreeCarMenu";
import ComServHud from "./cfx-keydi-comserv/ComServHud";
import ComServMenu from "./cfx-keydi-comserv/ComServMenu";
import LockMenu from "./cfx-keydi-lockscript/LockMenu";
import InvoiceMenu, { InvoiceData } from "./cfx-keydi-invoice/InvoiceMenu";
import type { IpadPlayerData } from "./cfx-keydi-ipad/Ipad";
import PlaytimeShop, { PlaytimeShopData } from "./cfx-keydi-playtimeshop/PlaytimeShop";
import { Toaster } from "sonner";
import { AlertTriangle } from "lucide-react";

const Ipad = lazy(() => import("./cfx-keydi-ipad/Ipad"));

interface IndicatorSettings {
  deadText: string;
  deadIcon: string;
  fontFamily: string;
  fontSize: number;
  duration: number;
  healthColor: string;
  armorColor: string;
}

const DEFAULT_INDICATOR_SETTINGS: IndicatorSettings = {
  deadText: "Dead",
  deadIcon: "skull",
  fontFamily: "JetBrains Mono",
  fontSize: 18,
  duration: 3.0,
  healthColor: "#f87171",
  armorColor: "#60a5fa"
};

// Cinematic Purge Siren Audio Synthesizer (City-Wide Alert Horn)
function playPurgeSirenAudio(durationMs = 12000) {
  try {
    const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
    if (!AudioContextClass) return;
    const ctx = new AudioContextClass();
    if (ctx.state === "suspended") {
      ctx.resume();
    }

    const now = ctx.currentTime;
    const duration = durationMs / 1000;

    // Master Gain with Fade In/Out
    const masterGain = ctx.createGain();
    masterGain.gain.setValueAtTime(0.001, now);
    masterGain.gain.exponentialRampToValueAtTime(0.38, now + 1.2);
    masterGain.gain.setValueAtTime(0.38, now + duration - 2.0);
    masterGain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

    // Warm Lowpass Filter for distant city echo
    const filter = ctx.createBiquadFilter();
    filter.type = "lowpass";
    filter.frequency.setValueAtTime(1300, now);

    // Reverb / Echo delay unit
    const delay = ctx.createDelay();
    delay.delayTime.setValueAtTime(0.42, now);
    const delayGain = ctx.createGain();
    delayGain.gain.setValueAtTime(0.38, now);

    // Deep Sub Bass Horn (Purge Fog Horn Drone)
    const droneOsc = ctx.createOscillator();
    droneOsc.type = "sawtooth";
    droneOsc.frequency.setValueAtTime(58, now);
    const droneGain = ctx.createGain();
    droneGain.gain.setValueAtTime(0.28, now);
    droneOsc.connect(droneGain);
    droneGain.connect(filter);

    // Siren Wailer 1 (Iconic Purge Pitch Sweep)
    const sirenOsc1 = ctx.createOscillator();
    sirenOsc1.type = "sawtooth";

    // Siren Wailer 2 (Chorus detune for thick ominous sound)
    const sirenOsc2 = ctx.createOscillator();
    sirenOsc2.type = "triangle";

    const cycleTime = 3.6;
    const totalCycles = Math.ceil(duration / cycleTime);
    for (let i = 0; i < totalCycles; i++) {
      const t = now + i * cycleTime;
      sirenOsc1.frequency.setValueAtTime(240, t);
      sirenOsc1.frequency.exponentialRampToValueAtTime(490, t + cycleTime * 0.45);
      sirenOsc1.frequency.exponentialRampToValueAtTime(240, t + cycleTime);

      sirenOsc2.frequency.setValueAtTime(242, t);
      sirenOsc2.frequency.exponentialRampToValueAtTime(494, t + cycleTime * 0.45);
      sirenOsc2.frequency.exponentialRampToValueAtTime(242, t + cycleTime);
    }

    const sirenGain = ctx.createGain();
    sirenGain.gain.setValueAtTime(0.32, now);
    sirenOsc1.connect(sirenGain);
    sirenOsc2.connect(sirenGain);
    sirenGain.connect(filter);

    // Output routing
    filter.connect(masterGain);
    filter.connect(delay);
    delay.connect(delayGain);
    delayGain.connect(masterGain);
    delayGain.connect(delay); // feedback loop
    masterGain.connect(ctx.destination);

    droneOsc.start(now);
    sirenOsc1.start(now);
    sirenOsc2.start(now);

    droneOsc.stop(now + duration);
    sirenOsc1.stop(now + duration);
    sirenOsc2.stop(now + duration);

    setTimeout(() => {
      try {
        ctx.close();
      } catch {}
    }, durationMs + 1000);
  } catch (e) {
    console.error("Purge siren audio error:", e);
  }
}

export default function App() {
  const [badgeVisible, setBadgeVisible] = useState(false);
  const [badgeData, setBadgeData] = useState<BadgeData | null>(null);
  
  const [radioChannel, setRadioChannel] = useState<string | null>("100.0 MHz");
  const [radioPlayers, setRadioPlayers] = useState<RadioPlayer[]>([]);
  const [radioHudVisible, setRadioHudVisible] = useState(false);
  const [radioModalVisible, setRadioModalVisible] = useState(false);
  const [radioEditMode, setRadioEditMode] = useState(false);
  const [scoreboardVisible, setScoreboardVisible] = useState(false);
  const [scoreboardData, setScoreboardData] = useState<any>({});
  
  const [indicatorConfigVisible, setIndicatorConfigVisible] = useState(false);
  const [indicatorSettings, setIndicatorSettings] = useState<IndicatorSettings>(DEFAULT_INDICATOR_SETTINGS);
  
  const [modulesVisible, setModulesVisible] = useState(false);
  const [modulesUpdates, setModulesUpdates] = useState<any[]>([]);
  const [rockstarRecording, setRockstarRecording] = useState(false);
  const [patchNotesVisible, setPatchNotesVisible] = useState(false);
  const [multiJobVisible, setMultiJobVisible] = useState(false);
  const [regionsVisible, setRegionsVisible] = useState(false);
  const [rockstarVisible, setRockstarVisible] = useState(false);
  const [vipVisible, setVipVisible] = useState(false);
  const [deathScreenVisible, setDeathScreenVisible] = useState(false);
  const [deathScreenData, setDeathScreenData] = useState<DeathScreenData | null>(null);
  const [fpsVisible, setFpsVisible] = useState(false);
  const [fpsPreset, setFpsPreset] = useState("default");
  const [fpsPresets, setFpsPresets] = useState<Record<string, FpsPreset>>({});
  const [reportVisible, setReportVisible] = useState(false);
  const [openReport, setOpenReport] = useState<OpenReport | null>(null);
  const [reportCategories, setReportCategories] = useState<ReportCategory[]>([]);
  const [reportMaxDescription, setReportMaxDescription] = useState(500);
  const [reportMaxTitle, setReportMaxTitle] = useState(80);
  const [reportIsAdmin, setReportIsAdmin] = useState(false);
  const [reportAllReports, setReportAllReports] = useState<any[]>([]);
  const [reportAdminDuty, setReportAdminDuty] = useState(false);

  const [bankingVisible, setBankingVisible] = useState(false);
  const [bankingData, setBankingData] = useState<any>(null);
  const [bankingIsATM, setBankingIsATM] = useState(false);

  const [welcomeVisible, setWelcomeVisible] = useState(false);
  const [welcomeData, setWelcomeData] = useState<any>({});

  const [marketVisible, setMarketVisible] = useState(false);
  const [marketData, setMarketData] = useState<MarketData | null>(null);

  const [freeCarVisible, setFreeCarVisible] = useState(false);
  const [freeCarData, setFreeCarData] = useState<FreeCarData | null>(null);

  const [comServMenuVisible, setComServMenuVisible] = useState(false);
  const [comServMenuData, setComServMenuData] = useState<any>(null);

  const [lockMenuVisible, setLockMenuVisible] = useState(false);
  const [lockMenuData, setLockMenuData] = useState<any>(null);
  const [welcomeBannerPanelVisible, setWelcomeBannerPanelVisible] = useState(false);
  const [welcomeBannerPanelData, setWelcomeBannerPanelData] = useState<WelcomeBannerPanelData | null>(null);
  const [welcomeBannerVolumeVisible, setWelcomeBannerVolumeVisible] = useState(false);
  const [welcomeBannerVolumeData, setWelcomeBannerVolumeData] = useState<WelcomeBannerVolumeData | null>(null);

  const [invoiceVisible, setInvoiceVisible] = useState(false);
  const [invoiceData, setInvoiceData] = useState<InvoiceData | null>(null);

  const [ipadVisible, setIpadVisible] = useState(false);
  const [ipadData, setIpadData] = useState<IpadPlayerData | null>(null);
  const [playtimeVisible, setPlaytimeVisible] = useState(false);
  const [playtimeData, setPlaytimeData] = useState<PlaytimeShopData | null>(null);

  const [announcementVisible, setAnnouncementVisible] = useState(false);
  const [announcementMessage, setAnnouncementMessage] = useState("");
  const [announcementSender, setAnnouncementSender] = useState("");

  useEffect(() => {
    if (announcementVisible) {
      const timer = setTimeout(() => {
        setAnnouncementVisible(false);
      }, 8000);
      return () => clearTimeout(timer);
    }
  }, [announcementVisible]);

  useEffect(() => {
    // Determine if we are running in the browser dev environment
    const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
    if (isBrowser) {
      setScoreboardVisible(false); 
      setIndicatorConfigVisible(false); 
      setModulesVisible(false);
      setFpsVisible(false);
      setWelcomeVisible(false);
      setBadgeVisible(false);
      setRadioHudVisible(false);
      setIpadVisible(true);
      // Prod-default: citizen iPad. Preview staff apps with ?preview=police|boss|owner
      // Playtime shop: ?preview=shop | Autofarm: ?preview=autofarm | Modules: ?preview=modules | Death: ?preview=deathscreen
      const preview = new URLSearchParams(window.location.search).get("preview") || "citizen";
      const isOwner = preview === "owner";
      const isBoss = preview === "boss" || isOwner;
      const isPolice = preview === "police" || isBoss;
      setIpadData({
        firstName: "Karl",
        lastName: "Dev",
        cash: 2450,
        bank: 128400,
        job: isPolice ? "Police" : "Unemployed",
        gang: "None",
        canEditEconomy: isOwner,
        canPoliceBoss: isBoss,
        canPoliceMdt: isPolice,
      });
      if (preview === "shop") {
        setIpadVisible(false);
        setPlaytimeVisible(true);
        setPlaytimeData(null);
      }
      if (preview === "autofarm") {
        setIpadVisible(false);
      }
      if (preview === "deathscreen") {
        setIpadVisible(false);
        setDeathScreenVisible(true);
        setDeathScreenData(PREVIEW_DEATH);
      }
      if (preview === "modules") {
        setIpadVisible(false);
        setModulesVisible(true);
        setModulesUpdates([
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
        ]);
        setReportCategories([
          { id: "bug", label: "Bug Report" },
          { id: "player", label: "Player Report" },
          { id: "other", label: "Other" },
        ]);
        setBankingData({
          playerName: "Karl Dev",
          accountNumber: "GC-882194",
          bankBalance: 128400,
          cashBalance: 2450,
          transactions: [
            {
              id: "1",
              type: "deposit",
              label: "Salary",
              amount: 2500,
              date: "Today",
            },
          ],
        });
      }
      setFreeCarVisible(false);
    }

    const handleMessage = (event: MessageEvent) => {
      const data = event.data;
      if (!data || typeof data !== "object") return;

      // Scoreboard UI Handlers
      if (data.action === "scoreboard:show") {
        if (data.data) setScoreboardData(data.data);
        setScoreboardVisible(true);
      } else if (data.action === "scoreboard:hide") {
        setScoreboardVisible(false);
      } else if (data.action === "scoreboard:update") {
        if (data.data) setScoreboardData(data.data);
      }

      // Community Service staff panel
      if (data.action === "cfx-keydi-comserv:panel:show") {
        if (data.data) setComServMenuData(data.data);
        setComServMenuVisible(true);
      } else if (data.action === "cfx-keydi-comserv:panel:hide") {
        setComServMenuVisible(false);
      } else if (data.action === "cfx-keydi-comserv:panel:update") {
        if (data.data) {
          setComServMenuData((prev: any) => ({ ...(prev || {}), ...data.data }));
        }
      }

      // VIP appearance lock panel
      if (data.action === "cfx-keydi-lockscript:panel:show") {
        if (data.data) setLockMenuData(data.data);
        setLockMenuVisible(true);
      } else if (data.action === "cfx-keydi-lockscript:panel:hide") {
        setLockMenuVisible(false);
      } else if (data.action === "cfx-keydi-lockscript:panel:update") {
        if (data.data) {
          setLockMenuData((prev: any) => ({ ...(prev || {}), ...data.data }));
        }
      }

      if (data.action === "cfx-keydi-welcomebanner:panel:show") {
        if (data.data) setWelcomeBannerPanelData(data.data);
        setWelcomeBannerPanelVisible(true);
      } else if (data.action === "cfx-keydi-welcomebanner:panel:hide") {
        setWelcomeBannerPanelVisible(false);
      } else if (data.action === "cfx-keydi-welcomebanner:panel:update") {
        if (data.data) {
          setWelcomeBannerPanelData((prev) => ({ ...(prev || {}), ...data.data }));
        }
      }

      if (data.action === "cfx-keydi-welcomebanner:volume:show") {
        if (data.data) setWelcomeBannerVolumeData(data.data);
        setWelcomeBannerVolumeVisible(true);
      } else if (data.action === "cfx-keydi-welcomebanner:volume:hide") {
        setWelcomeBannerVolumeVisible(false);
      }

      // Indicator UI Handlers
      if (data.action === "indicator:showConfig") {
        if (data.settings) setIndicatorSettings(data.settings);
        setIndicatorConfigVisible(true);
      } else if (data.action === "indicator:hideConfig") {
        setIndicatorConfigVisible(false);
      }

      // Modules Menu UI Handlers
      if (data.action === "cfx-keydi-modules:show") {
        if (data.data?.updates) setModulesUpdates(data.data.updates);
        setModulesVisible(true);
      } else if (data.action === "cfx-keydi-modules:hide") {
        setModulesVisible(false);
      } else if (data.action === "cfx-keydi-modules:recording") {
        setRockstarRecording(!!data.recording);
      }

      // Death Screen
      if (data.action === "deathscreen:show") {
        if (data.data) setDeathScreenData(data.data as DeathScreenData);
        setDeathScreenVisible(true);
      } else if (data.action === "deathscreen:hide") {
        setDeathScreenVisible(false);
        setDeathScreenData(null);
      }

      // FPS Optimizer UI Handlers
      if (data.action === "cfx-keydi-fps:show") {
        if (data.preset) setFpsPreset(data.preset);
        if (data.presets) setFpsPresets(data.presets);
        setFpsVisible(true);
      } else if (data.action === "cfx-keydi-fps:hide") {
        setFpsVisible(false);
      }

      // Report System UI Handlers
      if (data.action === "cfx-keydi-report:show") {
        setOpenReport(data.openReport ?? null);
        if (data.categories) setReportCategories(data.categories);
        if (data.maxDescription) setReportMaxDescription(data.maxDescription);
        if (data.maxTitle) setReportMaxTitle(data.maxTitle);
        setReportIsAdmin(data.isAdmin ?? false);
        setReportAllReports(data.allReports ?? []);
        setReportAdminDuty(data.adminDutyStatus ?? false);
        setReportVisible(true);
      } else if (data.action === "cfx-keydi-report:hide") {
        setReportVisible(false);
      } else if (data.action === "cfx-keydi-report:update") {
        if (data.openReport) setOpenReport(data.openReport);
      } else if (data.action === "cfx-keydi-report:updateReport") {
        if (data.openReport) setOpenReport(data.openReport);
      } else if (data.action === "cfx-keydi-report:reportClosed") {
        setOpenReport(null);
      }

      // Banking UI Handlers
      if (data.action === "cfx-keydi-banking:show") {
        if (data.data) setBankingData(data.data);
        setBankingIsATM(!!data.isATM);
        setBankingVisible(true);
      } else if (data.action === "cfx-keydi-banking:hide") {
        setBankingVisible(false);
      } else if (data.action === "cfx-keydi-banking:update") {
        if (data.data) setBankingData(data.data);
      }

      // Welcome UI Handlers
      if (data.action === "cfx-keydi-welcome:show") {
        if (data.data) setWelcomeData(data.data);
        setWelcomeVisible(true);
      } else if (data.action === "cfx-keydi-welcome:hide") {
        setWelcomeVisible(false);
      } else if (data.action === "cfx-keydi-admin:announcementReceived") {
        setAnnouncementMessage(data.message || "");
        setAnnouncementSender(data.sender || "Staff");
        setAnnouncementVisible(true);
      }

      // Sell Market UI Handlers
      if (data.action === "cfx-keydi-market:show") {
        if (data.data) setMarketData(data.data);
        setMarketVisible(true);
      } else if (data.action === "cfx-keydi-market:hide") {
        setMarketVisible(false);
      } else if (data.action === "cfx-keydi-market:update") {
        if (data.data) setMarketData(data.data);
      }

      // Free Car Claim UI Handlers
      if (data.action === "cfx-keydi-freecar:show") {
        if (data.data) setFreeCarData(data.data);
        setFreeCarVisible(true);
      } else if (data.action === "cfx-keydi-freecar:hide") {
        setFreeCarVisible(false);
      }

      // Billing / Invoice UI Handlers
      if (data.action === "cfx-keydi-invoice:show") {
        if (data.data) setInvoiceData(data.data);
        setInvoiceVisible(true);
      } else if (data.action === "cfx-keydi-invoice:hide") {
        setInvoiceVisible(false);
      } else if (data.action === "cfx-keydi-invoice:update") {
        if (data.data) setInvoiceData(data.data);
      }

      // Apple iPad System
      if (data.action === "cfx-keydi-ipad:open") {
        if (data.data) setIpadData(data.data);
        setIpadVisible(true);
      } else if (data.action === "cfx-keydi-ipad:session") {
        if (data.data) {
          setIpadData((prev) => ({ ...(prev || {}), ...data.data }));
        }
      } else if (data.action === "cfx-keydi-ipad:close") {
        setIpadVisible(false);
      }

      // Playtime Shop
      if (data.action === "cfx-keydi-playtimeshop:open") {
        if (data.data) setPlaytimeData(data.data);
        setPlaytimeVisible(true);
      } else if (data.action === "cfx-keydi-playtimeshop:update") {
        if (data.data) {
          setPlaytimeData((prev) => ({ ...(prev || {}), ...data.data }));
        }
      } else if (data.action === "cfx-keydi-playtimeshop:close") {
        setPlaytimeVisible(false);
      }

      // Police & Sheriff Badge UI Handlers
      if (data.action === "cfx-keydi-badge:show" || data.action === "showBadge") {
        if (data.data) setBadgeData(data.data);
        setBadgeVisible(true);
      } else if (data.action === "cfx-keydi-badge:hide" || data.action === "hideBadge") {
        setBadgeVisible(false);
      }

      // Radio List UI Handlers
      if (data.action === "cfx-keydi-radiolist:update" || data.type === "RadioUpdate") {
        const payload = data.data || data;
        if (payload.channel !== undefined) setRadioChannel(payload.channel);
        if (payload.players !== undefined) setRadioPlayers(payload.players);
        if (payload.hudVisible !== undefined) setRadioHudVisible(payload.hudVisible);
        if (payload.modalVisible !== undefined) setRadioModalVisible(payload.modalVisible);
      } else if (data.action === "cfx-keydi-radiolist:startDrag") {
        setRadioEditMode(true);
      }
    };

    const handleKeyDown = (event: KeyboardEvent) => {
      const activeKey = scoreboardData.toggleKey || "F10";
      const isPressingToggle = event.key.toLowerCase() === activeKey.toLowerCase();
      const isPressingEscape = event.key === "Escape";

      if (isPressingToggle || isPressingEscape) {
        const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
        if (isBrowser) {
          setScoreboardVisible(false);
          setIndicatorConfigVisible(false);
          setModulesVisible(false);
          setFpsVisible(false);
          setReportVisible(false);
          setBankingVisible(false);
          setWelcomeVisible(false);
          return;
        }

        const resourceName = (window as any).GetParentResourceName 
          ? (window as any).GetParentResourceName() 
          : "kodebykarl-ui";

        if (scoreboardVisible && (isPressingToggle || isPressingEscape)) {
          fetch(`https://${resourceName}/closeScoreboard`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (indicatorConfigVisible && isPressingEscape) {
          fetch(`https://${resourceName}/indicator:closeConfig`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (modulesVisible && isPressingEscape) {
          fetch(`https://${resourceName}/cfx-keydi-modules:closeMenu`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (fpsVisible && isPressingEscape) {
          fetch(`https://${resourceName}/cfx-keydi-fps:close`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (reportVisible && isPressingEscape) {
          fetch(`https://${resourceName}/cfx-keydi-report:close`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (bankingVisible && isPressingEscape) {
          fetch(`https://${resourceName}/cfx-keydi-banking:close`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (welcomeVisible && isPressingEscape) {
          fetch(`https://${resourceName}/cfx-keydi-welcome:close`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }

        if (invoiceVisible && isPressingEscape) {
          fetch(`https://${resourceName}/cfx-keydi-invoice:close`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({})
          }).catch(() => {});
        }
      }
    };

    window.addEventListener("message", handleMessage);
    window.addEventListener("keydown", handleKeyDown);

    return () => {
      window.removeEventListener("message", handleMessage);
      window.removeEventListener("keydown", handleKeyDown);
    };
  }, [scoreboardData, scoreboardVisible, indicatorConfigVisible, modulesVisible, fpsVisible, reportVisible, bankingVisible, welcomeVisible, comServMenuVisible, lockMenuVisible, invoiceVisible]);

  const isBrowserPreview =
    typeof window !== "undefined" &&
    !(window as any).invokeNative &&
    !navigator.userAgent.includes("FiveM");
  const isModulesPreview =
    isBrowserPreview &&
    new URLSearchParams(window.location.search).get("preview") === "modules";

  const returnToModulesPreview = () => {
    if (!isModulesPreview) return;
    setIndicatorConfigVisible(false);
    setFpsVisible(false);
    setReportVisible(false);
    setBankingVisible(false);
    setPatchNotesVisible(false);
    setMultiJobVisible(false);
    setRegionsVisible(false);
    setRockstarVisible(false);
    setVipVisible(false);
    setDeathScreenVisible(false);
    setModulesVisible(true);
  };

  const openModulePage = (open: () => void) => {
    setModulesVisible(false);
    open();
  };

  const closeModulePage = (close: () => void) => {
    close();
    if (isBrowserPreview) {
      returnToModulesPreview();
      return;
    }
    setModulesVisible(true);
  };

  return (
    <>
      {scoreboardVisible && <Scoreboard data={scoreboardData} />}
      {comServMenuVisible && (
        <ComServMenu
          data={comServMenuData}
          onClose={() => {
            const resourceName = (window as any).GetParentResourceName
              ? (window as any).GetParentResourceName()
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-comserv:close`, {
              method: "POST",
              headers: { "Content-Type": "application/json; charset=UTF-8" },
              body: JSON.stringify({}),
            }).catch(() => {});
          }}
        />
      )}
      {lockMenuVisible && (
        <LockMenu
          data={lockMenuData}
          onClose={() => {
            const resourceName = (window as any).GetParentResourceName
              ? (window as any).GetParentResourceName()
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-lockscript:close`, {
              method: "POST",
              headers: { "Content-Type": "application/json; charset=UTF-8" },
              body: JSON.stringify({}),
            }).catch(() => {});
          }}
        />
      )}
      {welcomeBannerPanelVisible && (
        <WelcomeBannerPanel
          data={welcomeBannerPanelData}
          onClose={() => {
            const resourceName = (window as any).GetParentResourceName
              ? (window as any).GetParentResourceName()
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-welcomebanner:close`, {
              method: "POST",
              headers: { "Content-Type": "application/json; charset=UTF-8" },
              body: JSON.stringify({}),
            }).catch(() => {});
            setWelcomeBannerPanelVisible(false);
          }}
        />
      )}
      {welcomeBannerVolumeVisible && (
        <WelcomeBannerVolume
          data={welcomeBannerVolumeData}
          onClose={() => {
            const resourceName = (window as any).GetParentResourceName
              ? (window as any).GetParentResourceName()
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-welcomebanner:volume:close`, {
              method: "POST",
              headers: { "Content-Type": "application/json; charset=UTF-8" },
              body: JSON.stringify({}),
            }).catch(() => {});
            setWelcomeBannerVolumeVisible(false);
          }}
        />
      )}
      {indicatorConfigVisible && (
        <IndicatorConfig 
          settings={indicatorSettings} 
          onClose={() => {
            if (isBrowserPreview) {
              setIndicatorConfigVisible(false);
              returnToModulesPreview();
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/indicator:closeConfig`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
        />
      )}
      
      {rockstarRecording && (
        <div className="pointer-events-none fixed top-5 left-1/2 z-[90] -translate-x-1/2">
          <div className="flex items-center gap-2 rounded-full border border-red-500/50 bg-black/70 px-3 py-1.5 shadow-[0_0_16px_rgba(239,68,68,0.35)]">
            <span className="h-2.5 w-2.5 animate-pulse rounded-full bg-red-500" />
            <span className="text-[11px] font-black tracking-[0.22em] text-red-400">REC</span>
          </div>
        </div>
      )}

      {modulesVisible && (
        <ModulesMenu
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setModulesVisible(false);
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-modules:closeMenu`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
          onOpenDamageIndicator={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              openModulePage(() => setIndicatorConfigVisible(true));
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-modules:openDamageIndicator`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
          onOpenFpsOptimizer={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              openModulePage(() => setFpsVisible(true));
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-modules:openFpsOptimizer`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
          onOpenReport={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              openModulePage(() => setReportVisible(true));
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-modules:openReport`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
          onOpenPatchNotes={() => openModulePage(() => setPatchNotesVisible(true))}
          onOpenMultiJob={() => openModulePage(() => setMultiJobVisible(true))}
          onOpenRegions={() => openModulePage(() => setRegionsVisible(true))}
          onOpenRockstar={() => openModulePage(() => setRockstarVisible(true))}
          onOpenVip={() => openModulePage(() => setVipVisible(true))}
          onOpenDeathScreen={() => {
            openModulePage(() => {
              setDeathScreenData(PREVIEW_DEATH);
              setDeathScreenVisible(true);
            });
          }}
        />
      )}

      {patchNotesVisible && (
        <PatchNotes
          initialUpdates={modulesUpdates}
          onClose={() => closeModulePage(() => setPatchNotesVisible(false))}
        />
      )}
      {multiJobVisible && (
        <MultiJob onClose={() => closeModulePage(() => setMultiJobVisible(false))} />
      )}
      {regionsVisible && (
        <Regions onClose={() => closeModulePage(() => setRegionsVisible(false))} />
      )}
      {rockstarVisible && (
        <RockstarRecording
          onRecordingChange={setRockstarRecording}
          onClose={() => closeModulePage(() => setRockstarVisible(false))}
        />
      )}
      {vipVisible && (
        <VipStatus onClose={() => closeModulePage(() => setVipVisible(false))} />
      )}

      {deathScreenVisible && (
        <DeathScreen
          data={deathScreenData}
          onClose={() => {
            setDeathScreenVisible(false);
            setDeathScreenData(null);
            if (isBrowserPreview) {
              const preview = new URLSearchParams(window.location.search).get("preview");
              if (preview === "modules") returnToModulesPreview();
            }
          }}
        />
      )}

      {fpsVisible && (
        <FpsOptimizer
          initialPreset={fpsPreset}
          presets={Object.keys(fpsPresets).length > 0 ? fpsPresets : undefined}
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setFpsVisible(false);
              returnToModulesPreview();
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-fps:close`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
        />
      )}

      <ReportSystem
          isOpen={reportVisible}
          categories={reportCategories.length > 0 ? reportCategories : undefined}
          initialReport={openReport}
          maxDescription={reportMaxDescription}
          maxTitle={reportMaxTitle}
          initialIsAdmin={reportIsAdmin}
          initialAllReports={reportAllReports}
          initialAdminDuty={reportAdminDuty}
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setReportVisible(false);
              returnToModulesPreview();
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-report:close`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
        />

      {bankingVisible && (
        <BankingSystem
          initialData={bankingData}
          isATM={bankingIsATM}
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setBankingVisible(false);
              returnToModulesPreview();
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-banking:close`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
        />
      )}

      {welcomeVisible && (
        <WelcomeScreen
          data={welcomeData}
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setWelcomeVisible(false);
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-welcome:close`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
          }}
        />
      )}

      {badgeVisible && (
        <Badge
          visible={badgeVisible}
          data={badgeData ?? undefined}
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setBadgeVisible(false);
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-badge:close`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
            setBadgeVisible(false);
          }}
        />
      )}

      {/* Radio List HUD & Roster Modal */}
      <RadioListHud
        channel={radioChannel}
        players={radioPlayers}
        editMode={radioEditMode}
        hudVisible={radioHudVisible}
        onExitEdit={() => setRadioEditMode(false)}
      />

      {radioModalVisible && (
        <RadioListModal
          visible={radioModalVisible}
          channel={radioChannel}
          players={radioPlayers}
          onClose={() => {
            const isBrowser = !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");
            if (isBrowser) {
              setRadioModalVisible(false);
              return;
            }
            const resourceName = (window as any).GetParentResourceName 
              ? (window as any).GetParentResourceName() 
              : "kodebykarl-ui";
            fetch(`https://${resourceName}/cfx-keydi-radiolist:closeModal`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8"
              },
              body: JSON.stringify({})
            }).catch(() => {});
            setRadioModalVisible(false);
          }}
        />
      )}
      
      {/* Damage indicator overlays (always listening for damage events) */}
      <DamageOverlay currentSettings={indicatorSettings} />

      {/* Chat overlay container */}
      <Chat />

      {/* Impound Countdown Alerts */}
      <ImpoundNotification />

      {/* Auto Farm HUD (shown while standing in a farm marker) */}
      <AutofarmHud />

      {/* Welcome banner (.wcb) — bottom-right 65x65 overlay */}
      <WelcomeBanner />

      {/* Community Service HUD */}
      <ComServHud />

      {/* Grind Sell Market UI */}
      <MarketMenu visible={marketVisible} data={marketData || undefined} onClose={() => setMarketVisible(false)} />

      {/* Free Car Claim UI */}
      <FreeCarMenu visible={freeCarVisible} data={freeCarData || undefined} onClose={() => setFreeCarVisible(false)} />

      {/* Billing / Invoice System */}
      <InvoiceMenu visible={invoiceVisible} data={invoiceData || undefined} onClose={() => setInvoiceVisible(false)} />

      {/* Playtime Shop */}
      <PlaytimeShop
        visible={playtimeVisible}
        data={playtimeData}
        onClose={() => setPlaytimeVisible(false)}
      />

      {/* Apple iPad System — mount only while open (0 timers when closed) */}
      {ipadVisible ? (
        <Suspense fallback={null}>
          <Ipad visible={ipadVisible} data={ipadData} onClose={() => setIpadVisible(false)} />
        </Suspense>
      ) : null}

      {announcementVisible && (
        <div 
          className="pandora fixed top-6 left-1/2 -translate-x-1/2 z-[99999] flex items-center gap-3.5 p-3 border text-white rounded-lg w-[360px] animate-tx-announcement pointer-events-none text-left shadow-lg"
          style={{ backgroundColor: "#082744", borderColor: "rgba(255, 122, 181, 0.26)" }}
        >
          <AlertTriangle className="h-5 w-5 text-amber-500 shrink-0" fill="currentColor" />
          <div className="flex-1 min-w-0">
            <h4 className="text-[11px] font-black uppercase text-muted-foreground tracking-wider leading-tight">
              Announcement by {announcementSender}
            </h4>
            <p className="mt-0.5 text-xs font-bold text-white leading-relaxed whitespace-pre-wrap">
              {announcementMessage}
            </p>
          </div>
        </div>
      )}

      <Toaster position="top-right" richColors />
    </>
  );
}
