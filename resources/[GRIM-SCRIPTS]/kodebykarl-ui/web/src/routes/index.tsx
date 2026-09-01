import { useState } from "react";
import { format } from "date-fns";
import {
  CalendarIcon, User, Globe, Ruler, Users, ArrowRight, Home, FileText,
  Sparkles, Wrench, ShieldCheck, Zap, Gamepad2, Building2, Check,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import pandoraLogo from "@/assets/pandora-city-logo.png";

type Tab = "identity" | "updates";

type UpdateTag = "Feature" | "Fix" | "Security" | "Performance";

const SERVER_UPDATES: {
  version: string;
  date: string;
  title: string;
  tag: UpdateTag;
  notes: string[];
}[] = [
    {
      version: "v2.4.0",
      date: "June 24, 2026",
      title: "Pandora Bay Expansion — Lighthouse District",
      tag: "Feature",
      notes: [
        "Added 12 new interiors across the Lighthouse District including beach houses and marina garages.",
        "New /apartment system with shared keys, decoration menu, and tenant logs.",
        "Reworked spawn flow — new players now choose between three district intros.",
      ],
    },
    {
      version: "v2.3.2",
      date: "June 18, 2026",
      title: "Anti-Cheat & Identity Verification",
      tag: "Security",
      notes: [
        "Hardened anti-injection module — auto-bans now include a 24h review window.",
        "Identity registration now requires DOB between 1990 and 2005 in-character.",
        "Discord role sync is now real-time when linking your account.",
      ],
    },
    {
      version: "v2.3.1",
      date: "June 11, 2026",
      title: "Performance Pass — Server Tick & Streaming",
      tag: "Performance",
      notes: [
        "Reduced average server tick from 18ms → 9ms during peak hours.",
        "Object streaming radius optimized for vehicles above 120 km/h.",
        "Voice chat now uses opus 48kHz with adaptive bitrate.",
      ],
    },
    {
      version: "v2.3.0",
      date: "June 02, 2026",
      title: "Job System Overhaul",
      tag: "Fix",
      notes: [
        "Fixed payout desync on Trucker and Mechanic jobs.",
        "/report now creates a ticket directly in the staff panel with logs attached.",
        "Resolved 14 community-reported issues from the May feedback thread.",
      ],
    },
  ];

const HERO_CHIPS = [
  { icon: <Gamepad2 className="h-3 w-3" />, label: "Roleplay" },
  { icon: <Users className="h-3 w-3" />, label: "Community" },
  { icon: <Building2 className="h-3 w-3" />, label: "Your City" },
];

export default function Index() {
  const [tab, setTab] = useState<Tab>("identity");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [dob, setDob] = useState<Date | undefined>();
  const [nationality, setNationality] = useState("");
  const [height, setHeight] = useState("");
  const [gender, setGender] = useState("");

  const age = dob ? Math.floor((Date.now() - dob.getTime()) / (365.25 * 24 * 60 * 60 * 1000)) : null;

  const filled = [firstName, lastName, dob, nationality, height, gender].filter(Boolean).length;
  const progress = Math.round((filled / 6) * 100);

  const handleSubmit = async () => {
    if (!firstName || !lastName || !dob || !nationality || !height || !gender) {
      toast.error("Please fill in all fields.");
      return;
    }

    const heightNum = parseInt(height);
    if (isNaN(heightNum) || heightNum < 120 || heightNum > 220) {
      toast.error("Height must be between 120 and 220 cm.");
      return;
    }

    const payload = {
      firstName,
      lastName,
      dob: dob.getTime(),
      nationality,
      height: heightNum,
      gender,
    };

    try {
      const response = await fetch(`https://${(window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'cfx-keydi-ui'}/submitIdentity`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(payload),
      });
      const result = await response.json();
      if (result && result.error) {
        toast.error(result.error);
      }
    } catch (error) {
      console.error("Failed to submit identity to NUI:", error);
      toast.error("Failed to communicate with game client.");
    }
  };

  return (
    <div className="pandora flex min-h-screen items-center justify-center p-8 font-sans">
      <div className="pandora-shell w-full max-w-6xl overflow-hidden rounded-[26px] backdrop-blur-xl">
        {/* Top nav */}
        <div className="flex items-center justify-between border-b border-white/10 px-6 py-3.5">
          <div className="flex items-center gap-5">
            <div className="flex items-center gap-2.5">
              <img src={pandoraLogo} alt="Pandora City" className="h-9 w-9 object-contain" />
              <div className="pandora-display leading-none">
                <p className="text-[12px] font-bold tracking-[0.22em] text-white">PANDORA</p>
                <p className="text-[9px] font-semibold tracking-[0.38em]" style={{ color: "var(--pandora-sun)" }}>CITY</p>
              </div>
            </div>
            <span className="h-8 w-px bg-white/10" />
            <div className="flex items-center gap-2">
              <TabButton active={tab === "identity"} onClick={() => setTab("identity")} icon={<Home className="h-3.5 w-3.5" />}>
                Identity
              </TabButton>
              <TabButton active={tab === "updates"} onClick={() => setTab("updates")} icon={<FileText className="h-3.5 w-3.5" />}>
                Server Updates
              </TabButton>
            </div>
          </div>

          <div className="flex items-center gap-4">
            {tab === "identity" && (
              <div className="hidden items-center gap-2.5 md:flex">
                <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-[#9cc3e6]">
                  {filled}/6 complete
                </span>
                <div className="h-1.5 w-24 overflow-hidden rounded-full bg-white/10">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{
                      width: `${progress}%`,
                      background: "linear-gradient(90deg, var(--pandora-cyan), var(--pandora-pink))",
                    }}
                  />
                </div>
              </div>
            )}
            <Button onClick={handleSubmit} className="pandora-cta pointer-events-auto rounded-full px-5 font-bold">
              Continue <ArrowRight className="ml-1 h-4 w-4" />
            </Button>
          </div>
        </div>

        <div className="grid grid-cols-[360px_1fr] gap-0">
          {/* Left hero panel */}
          <div className="pandora-hero relative flex flex-col items-center justify-between overflow-hidden border-r border-white/10 p-8">
            {/* Sun glow */}
            <div
              className="pointer-events-none absolute -top-24 left-1/2 h-64 w-64 -translate-x-1/2 rounded-full"
              style={{ background: "radial-gradient(circle, rgba(255, 210, 76, 0.45) 0%, transparent 68%)" }}
            />
            {/* Sea foam */}
            <div className="pandora-waves pointer-events-none absolute inset-x-0 bottom-0 h-52" />

            <img src={pandoraLogo} alt="Pandora City" className="pandora-logo relative z-10 w-[190px] object-contain" />

            <div className="relative z-10 text-center">
              {tab === "identity" ? (
                <>
                  <h2 className="pandora-display text-[15px] font-semibold uppercase tracking-[0.3em] text-white/80">Create your</h2>
                  <h1 className="pandora-title mt-1 text-[38px] font-black leading-none">Identity</h1>
                  <p className="mx-auto mt-3 max-w-[250px] text-[11.5px] leading-relaxed text-[#cfe7ff]">
                    Set up your character profile. This is who you will be in Pandora City.
                  </p>
                </>
              ) : (
                <>
                  <h2 className="pandora-display text-[15px] font-semibold uppercase tracking-[0.3em] text-white/80">Patch Notes</h2>
                  <h1 className="pandora-title mt-1 text-[30px] font-black leading-none">Server Updates</h1>
                  <p className="mx-auto mt-3 max-w-[250px] text-[11.5px] leading-relaxed text-[#cfe7ff]">
                    Everything new, fixed, and improved across the Pandora City roleplay world.
                  </p>
                </>
              )}

              <div className="mt-5 flex flex-wrap items-center justify-center gap-2">
                {HERO_CHIPS.map((chip) => (
                  <span
                    key={chip.label}
                    className="inline-flex items-center gap-1.5 rounded-full border border-white/25 bg-white/10 px-2.5 py-1 text-[9.5px] font-bold uppercase tracking-wider text-white backdrop-blur-sm"
                  >
                    {chip.icon} {chip.label}
                  </span>
                ))}
              </div>
            </div>

            <p className="pandora-display relative z-10 text-[9.5px] font-semibold tracking-[0.34em]" style={{ color: "var(--pandora-sun)" }}>
              YOUR STORY. OUR CITY.
            </p>
          </div>

          {/* Right panel */}
          <div className="p-9">
            <div className="custom-scrollbar h-[450px] overflow-y-auto pr-3">
              {tab === "identity" ? (
                <IdentityForm
                  firstName={firstName} setFirstName={setFirstName}
                  lastName={lastName} setLastName={setLastName}
                  dob={dob} setDob={setDob} age={age}
                  nationality={nationality} setNationality={setNationality}
                  height={height} setHeight={setHeight}
                  gender={gender} setGender={setGender}
                />
              ) : (
                <ServerUpdates />
              )}
            </div>

            <div className="mt-7 flex items-center justify-between border-t border-white/10 pt-5">
              <p className="text-[11.5px] text-[#9cc3e6]">
                {tab === "identity"
                  ? "By continuing you agree to follow the server rules and code of conduct."
                  : "Updates are pushed by the development team. Last refresh just now."}
              </p>
              <div className="flex items-center gap-2">
                <span className="pandora-display text-[10px] font-semibold tracking-[0.24em]" style={{ color: "var(--pandora-pink-soft)" }}>
                  PANDORA CITY
                </span>
                <span className="h-3 w-px bg-white/15" />
                <span className="text-[10px] tracking-[0.2em] text-[#7ba7cc]">keydi</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function Field({
  icon,
  label,
  title,
  hint,
  done,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  title: string;
  hint?: string;
  done?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div className="pandora-card group p-4">
      <div className="flex items-center gap-2.5">
        <div className="pandora-icon flex h-8 w-8 shrink-0 items-center justify-center rounded-xl">
          {icon}
        </div>
        <div className="min-w-0 flex-1 leading-tight">
          <span className="text-[9px] font-black tracking-[0.24em]" style={{ color: "var(--pandora-sun)" }}>
            {label}
          </span>
          <p className="truncate text-[11px] font-bold uppercase tracking-wider text-[#cfe7ff]">
            {title}
            {hint && <span className="ml-1 font-medium normal-case tracking-normal text-[#7ba7cc]">{hint}</span>}
          </p>
        </div>
        {done && (
          <span
            className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full"
            style={{ background: "rgba(53, 199, 242, 0.2)", color: "var(--pandora-cyan-soft)" }}
          >
            <Check className="h-3 w-3" />
          </span>
        )}
      </div>
      <div className="mt-2.5 pl-[42px]">{children}</div>
    </div>
  );
}

function TabButton({
  active,
  onClick,
  icon,
  children,
}: {
  active: boolean;
  onClick: () => void;
  icon: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "flex items-center gap-2 rounded-full px-4 py-1.5 text-[12px] font-semibold transition",
        active
          ? "pandora-cta text-white"
          : "border border-white/10 bg-white/5 text-[#9cc3e6] hover:bg-white/10 hover:text-white",
      )}
    >
      {icon}
      <span>{children}</span>
    </button>
  );
}

const FIELD_INPUT = "border-0 bg-transparent px-0 text-base text-white placeholder:text-[#6f9dc4] focus-visible:ring-0";
const FIELD_TRIGGER = "h-auto w-full border-0 bg-transparent px-0 py-1 text-base text-white shadow-none focus:ring-0 data-[placeholder]:text-[#6f9dc4]";

function IdentityForm(props: {
  firstName: string; setFirstName: (v: string) => void;
  lastName: string; setLastName: (v: string) => void;
  dob: Date | undefined; setDob: (d: Date | undefined) => void;
  age: number | null;
  nationality: string; setNationality: (v: string) => void;
  height: string; setHeight: (v: string) => void;
  gender: string; setGender: (v: string) => void;
}) {
  const { firstName, setFirstName, lastName, setLastName, dob, setDob, age, nationality, setNationality, height, setHeight, gender, setGender } = props;
  return (
    <>
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="pandora-title text-[13px] font-black tracking-[0.28em]">CHARACTER DETAILS</p>
          <p className="mt-2 text-[13px] text-[#9cc3e6]">
            Fill in your in-character information below. All fields are required to enter the city.
          </p>
        </div>
        <span
          className="shrink-0 rounded-full border px-3 py-1 text-[9.5px] font-black uppercase tracking-[0.18em]"
          style={{ borderColor: "rgba(255, 210, 76, 0.45)", color: "var(--pandora-sun)", background: "rgba(255, 210, 76, 0.1)" }}
        >
          New Resident
        </span>
      </div>

      <div className="mt-6 grid grid-cols-2 gap-4">
        <Field icon={<User className="h-3.5 w-3.5" />} label="01" title="First Name" done={!!firstName}>
          <Input value={firstName} onChange={(e) => setFirstName(e.target.value)} placeholder="John" className={FIELD_INPUT} />
        </Field>
        <Field icon={<User className="h-3.5 w-3.5" />} label="02" title="Last Name" done={!!lastName}>
          <Input value={lastName} onChange={(e) => setLastName(e.target.value)} placeholder="Doe" className={FIELD_INPUT} />
        </Field>
        <Field
          icon={<CalendarIcon className="h-3.5 w-3.5" />}
          label="03"
          title="Date of Birth"
          hint={age !== null ? `· ${age} yrs` : undefined}
          done={!!dob}
        >
          <Popover>
            <PopoverTrigger asChild>
              <button className={cn("flex w-full items-center justify-between bg-transparent py-1 text-left text-base text-white outline-none", !dob && "text-[#6f9dc4]")}>
                {dob ? format(dob, "MMMM d, yyyy") : "Select your birthday"}
                <CalendarIcon className="h-4 w-4" style={{ color: "var(--pandora-pink)" }} />
              </button>
            </PopoverTrigger>
            <PopoverContent className="pandora pointer-events-auto z-50 w-auto border-border/60 bg-popover p-0" align="start">
              <Calendar
                mode="single"
                selected={dob}
                onSelect={setDob}
                captionLayout="dropdown"
                defaultMonth={dob ?? new Date(1997, 0)}
                startMonth={new Date(1990, 0)}
                endMonth={new Date(2005, 11)}
                disabled={(date) => { const y = date.getFullYear(); return y < 1990 || y > 2005; }}
              />
            </PopoverContent>
          </Popover>
        </Field>
        <Field icon={<Globe className="h-3.5 w-3.5" />} label="04" title="Nationality" done={!!nationality}>
          <Select value={nationality} onValueChange={setNationality}>
            <SelectTrigger className={FIELD_TRIGGER}>
              <SelectValue placeholder="Choose nationality" />
            </SelectTrigger>
            <SelectContent className="pandora pointer-events-auto z-50 max-h-72">
              {["American", "British", "Canadian", "Filipino", "Mexican", "Japanese", "Korean", "German", "French", "Australian", "Other"].map((n) => (
                <SelectItem key={n} value={n}>{n}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </Field>
        <Field icon={<Ruler className="h-3.5 w-3.5" />} label="05" title="Height (cm)" done={!!height}>
          <Input type="number" value={height} onChange={(e) => setHeight(e.target.value)} placeholder="175" className={FIELD_INPUT} />
        </Field>
        <Field icon={<Users className="h-3.5 w-3.5" />} label="06" title="Gender" done={!!gender}>
          <Select value={gender} onValueChange={setGender}>
            <SelectTrigger className={FIELD_TRIGGER}>
              <SelectValue placeholder="Select gender" />
            </SelectTrigger>
            <SelectContent className="pandora pointer-events-auto z-50">
              <SelectItem value="male">Male</SelectItem>
              <SelectItem value="female">Female</SelectItem>
              <SelectItem value="non-binary">Non-binary</SelectItem>
              <SelectItem value="prefer-not">Prefer not to say</SelectItem>
            </SelectContent>
          </Select>
        </Field>
      </div>
    </>
  );
}

const TAG_STYLES: Record<UpdateTag, { icon: React.ReactNode; bg: string; text: string }> = {
  Feature: { icon: <Sparkles className="h-3 w-3" />, bg: "rgba(255, 61, 150, 0.22)", text: "#ffb3d6" },
  Fix: { icon: <Wrench className="h-3 w-3" />, bg: "rgba(53, 199, 242, 0.22)", text: "#a8e7ff" },
  Security: { icon: <ShieldCheck className="h-3 w-3" />, bg: "rgba(64, 214, 161, 0.22)", text: "#a6f2d5" },
  Performance: { icon: <Zap className="h-3 w-3" />, bg: "rgba(255, 210, 76, 0.22)", text: "#ffe6a3" },
};

function ServerUpdates() {
  const [filter, setFilter] = useState<"all" | UpdateTag>("all");
  const visible = filter === "all" ? SERVER_UPDATES : SERVER_UPDATES.filter((u) => u.tag === filter);

  return (
    <>
      <div className="flex items-center justify-between">
        <div>
          <p className="pandora-title text-[13px] font-black tracking-[0.28em]">CHANGELOG</p>
          <p className="mt-2 text-[13px] text-[#9cc3e6]">
            Latest updates, fixes, and new features shipped to the city.
          </p>
        </div>
        <div className="flex gap-1 rounded-full border border-white/10 bg-white/5 p-1">
          {(["all", "Feature", "Fix", "Security", "Performance"] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={cn(
                "rounded-full px-3 py-1 text-[10px] font-bold uppercase tracking-wider transition",
                filter === f
                  ? "pandora-cta text-white"
                  : "text-[#9cc3e6] hover:text-white",
              )}
            >
              {f === "all" ? "All" : f}
            </button>
          ))}
        </div>
      </div>

      <div className="mt-6 space-y-4">
        {visible.map((u, i) => {
          const style = TAG_STYLES[u.tag];
          return (
            <article key={u.version} className="pandora-card p-5">
              <div className="flex flex-wrap items-center gap-3">
                <span
                  className="rounded-md border px-2 py-0.5 font-mono text-[11px] font-bold tracking-wider"
                  style={{
                    borderColor: "rgba(255, 210, 76, 0.35)",
                    background: "rgba(255, 210, 76, 0.12)",
                    color: "var(--pandora-sun)",
                  }}
                >
                  {u.version}
                </span>
                <span
                  className="inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-wider"
                  style={{ background: style.bg, color: style.text }}
                >
                  {style.icon} {u.tag}
                </span>
                <span className="text-[11px] text-[#7ba7cc]">{u.date}</span>
                {i === 0 && (
                  <span
                    className="ml-auto inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-[10px] font-bold tracking-widest"
                    style={{ borderColor: "rgba(255, 61, 150, 0.5)", color: "var(--pandora-pink-soft)" }}
                  >
                    <span className="h-1.5 w-1.5 animate-pulse rounded-full" style={{ background: "var(--pandora-pink)" }} />
                    LATEST
                  </span>
                )}
              </div>
              <h3 className="mt-3 text-base font-bold text-white">{u.title}</h3>
              <ul className="mt-3 space-y-1.5">
                {u.notes.map((n, idx) => (
                  <li key={idx} className="flex gap-2 text-sm leading-relaxed text-[#9cc3e6]">
                    <span className="mt-2 h-1 w-1 shrink-0 rounded-full" style={{ background: "var(--pandora-pink)" }} />
                    <span>{n}</span>
                  </li>
                ))}
              </ul>
            </article>
          );
        })}
        {visible.length === 0 && (
          <p className="rounded-xl border border-white/10 p-8 text-center text-sm text-[#9cc3e6]">
            No updates match this filter.
          </p>
        )}
      </div>
    </>
  );
}
