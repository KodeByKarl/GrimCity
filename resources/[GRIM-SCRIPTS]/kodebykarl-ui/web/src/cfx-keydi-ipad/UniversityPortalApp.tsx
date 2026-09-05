import React, { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  BookOpen,
  Building2,
  CalendarDays,
  GraduationCap,
  IdCard,
  MapPin,
  Plus,
  Search,
  Signal,
  Sparkles,
  Users,
  Wifi,
  Landmark,
  ClipboardList,
  Bell,
  ChevronRight,
  BadgeCheck,
} from "lucide-react";
import type { IpadPlayerData } from "./Ipad";
import type { UniversityRole } from "./universityTypes";
import { fetchNui, isBrowserEnv } from "@/lib/nui";

export type { UniversityRole };

type PendingApp = {
  id: number;
  citizenName?: string;
  programCode?: string;
  programLabel?: string;
  createdAt?: string;
};

type Course = {
  id: string;
  code: string;
  name: string;
  college: string;
  seats: number;
  enrolled: number;
  schedule: string;
  room: string;
};

const COLLEGES = [
  "College of Computing",
  "College of Nursing",
  "College of Criminal Justice",
  "College of Business",
  "College of Liberal Arts",
];

const MOCK_COURSES: Course[] = [
  {
    id: "1",
    code: "BSIT-101",
    name: "Introduction to Computing",
    college: "College of Computing",
    seats: 40,
    enrolled: 28,
    schedule: "Mon / Wed · 09:00",
    room: "Lab A · Chemistry Wing",
  },
  {
    id: "2",
    code: "BSN-210",
    name: "Fundamentals of Nursing",
    college: "College of Nursing",
    seats: 32,
    enrolled: 30,
    schedule: "Tue / Thu · 13:00",
    room: "Clinic Hall 2",
  },
  {
    id: "3",
    code: "CRIM-150",
    name: "Criminal Law & Procedure",
    college: "College of Criminal Justice",
    seats: 45,
    enrolled: 22,
    schedule: "Fri · 10:30",
    room: "Lecture Hall B",
  },
  {
    id: "4",
    code: "BSA-120",
    name: "Principles of Accounting",
    college: "College of Business",
    seats: 36,
    enrolled: 19,
    schedule: "Mon / Fri · 14:00",
    room: "Business Suite 3",
  },
  {
    id: "5",
    code: "ENG-180",
    name: "Academic Writing Workshop",
    college: "College of Liberal Arts",
    seats: 28,
    enrolled: 16,
    schedule: "Wed · 11:00",
    room: "Language Room · Spanish",
  },
];

const ROLE_META: Record<
  UniversityRole,
  { label: string; accent: string; blurb: string }
> = {
  visitor: {
    label: "Visitor",
    accent: "#c4a574",
    blurb: "Explore campus · Apply when ready",
  },
  student: {
    label: "Student",
    accent: "#6eb5ff",
    blurb: "Courses · ID · Schedule",
  },
  teacher: {
    label: "Faculty",
    accent: "#7dd3a8",
    blurb: "Classes · Roster · Grades",
  },
  dean: {
    label: "Dean",
    accent: "#e8b86d",
    blurb: "College oversight · Curriculum",
  },
  director: {
    label: "Director",
    accent: "#f0c27a",
    blurb: "Campus command · Programs",
  },
};

function StatusBar() {
  const [now, setNow] = useState(() => new Date());
  React.useEffect(() => {
    const id = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(id);
  }, []);
  const time = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  return (
    <div className="relative z-40 flex items-center justify-between px-7 pt-[18px] text-[12px] font-semibold tracking-tight text-[#f4efe6]/90">
      <span className="min-w-[54px]">{time}</span>
      <div className="flex items-center gap-1.5 opacity-90">
        <Signal className="h-3.5 w-3.5" strokeWidth={2.4} />
        <Wifi className="h-3.5 w-3.5" strokeWidth={2.4} />
        <BatteryFull className="h-4 w-4" strokeWidth={2.2} />
      </div>
    </div>
  );
}

function resolveRole(player?: IpadPlayerData | null): UniversityRole {
  if (player?.universityRole) return player.universityRole;
  return "visitor";
}

function SeatBar({ enrolled, seats }: { enrolled: number; seats: number }) {
  const pct = Math.min(100, Math.round((enrolled / Math.max(1, seats)) * 100));
  return (
    <div className="mt-2">
      <div className="flex items-center justify-between text-[11px] text-[#9aa3b2]">
        <span>
          {enrolled}/{seats} seats
        </span>
        <span>{pct}%</span>
      </div>
      <div className="mt-1 h-1.5 overflow-hidden rounded-full bg-white/8">
        <div
          className="h-full rounded-full bg-gradient-to-r from-[#c4a574] to-[#e8d5b0]"
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}

export default function UniversityPortalApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const role = resolveRole(player);
  const meta = ROLE_META[role];
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Guest";
  const [tab, setTab] = useState<"home" | "courses" | "campus" | "admin">(
    role === "visitor" ? "campus" : "home",
  );
  const [query, setQuery] = useState("");
  const [collegeFilter, setCollegeFilter] = useState<string>("All");
  const [courses, setCourses] = useState(MOCK_COURSES);
  const [enrolledIds, setEnrolledIds] = useState<string[]>(["1"]);
  const [toast, setToast] = useState<string | null>(null);
  const [draftCode, setDraftCode] = useState("");
  const [draftName, setDraftName] = useState("");
  const [draftCollege, setDraftCollege] = useState(COLLEGES[0]);
  const createCourse = () => {
    if (!draftCode.trim() || !draftName.trim()) {
      flash("Code and course name required");
      return;
    }
    const next: Course = {
      id: String(Date.now()),
      code: draftCode.trim().toUpperCase(),
      name: draftName.trim(),
      college: draftCollege,
      seats: 40,
      enrolled: 0,
      schedule: "TBA",
      room: "Assign room",
    };
    setCourses((prev) => [next, ...prev]);
    setDraftCode("");
    setDraftName("");
    flash("Course created · Keydi.dev portal");
    setTab("courses");
  };

  const isStaff = role === "teacher" || role === "dean" || role === "director";
  const isAdmin = role === "dean" || role === "director";

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return courses.filter((c) => {
      if (collegeFilter !== "All" && c.college !== collegeFilter) return false;
      if (!q) return true;
      return (
        c.name.toLowerCase().includes(q) ||
        c.code.toLowerCase().includes(q) ||
        c.college.toLowerCase().includes(q)
      );
    });
  }, [courses, collegeFilter, query]);

  const loadPending = React.useCallback(async () => {
    if (!(role === "dean" || role === "director")) return;
    setPendingLoading(true);
    const res = await fetchNui<{ ok?: boolean; rows?: PendingApp[] }>(
      "cfx-keydi-university:portal:pending",
    );
    setPendingLoading(false);
    if (isBrowserEnv()) {
      setPendingApps([
        {
          id: 1,
          citizenName: "Mia Cruz",
          programCode: "CJPS",
          programLabel: "Criminal Justice and Public Safety",
          createdAt: "just now",
        },
        {
          id: 2,
          citizenName: "Ace Walker",
          programCode: "BSIT",
          programLabel: "Information Technology",
          createdAt: "5m ago",
        },
      ]);
      return;
    }
    setPendingApps(res?.rows || []);
  }, [role]);

  React.useEffect(() => {
    if (tab === "admin" && (role === "dean" || role === "director")) {
      void loadPending();
    }
  }, [tab, role, loadPending]);

  const reviewApp = async (id: number, decision: "approve" | "deny") => {
    const res = await fetchNui<{ ok?: boolean; rows?: PendingApp[]; message?: string }>(
      "cfx-keydi-university:portal:review",
      { id, decision },
    );
    if (isBrowserEnv()) {
      setPendingApps((rows) => rows.filter((r) => r.id !== id));
      flash(decision === "approve" ? "Applicant approved" : "Application denied");
      return;
    }
    if (!res?.ok) {
      flash(res?.message || "Review failed");
      return;
    }
    setPendingApps(res.rows || []);
    flash(decision === "approve" ? "Applicant approved" : "Application denied");
  };

  const tabs = useMemo(() => {
    const list: { id: typeof tab; label: string }[] = [
      { id: "home", label: "Portal" },
      { id: "courses", label: "Courses" },
      { id: "campus", label: "Campus" },
    ];
    if (isAdmin) list.push({ id: "admin", label: "Director" });
    return list;
  }, [isAdmin]);

  return (
    <div
      className="absolute inset-0 flex flex-col select-none overflow-hidden"
      style={{
        fontFamily:
          '"Iowan Old Style", "Palatino Linotype", Palatino, "Book Antiqua", Georgia, "Times New Roman", serif',
        background:
          "radial-gradient(120% 80% at 0% 0%, #1a2740 0%, #0c111c 42%, #080a10 100%)",
      }}
    >
      {/* Atmosphere */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_80%_10%,rgba(196,165,116,0.16),transparent_42%)]" />
      <div className="pointer-events-none absolute -left-20 top-40 h-64 w-64 rounded-full bg-[#1e3a5f]/35 blur-3xl" />
      <div
        className="pointer-events-none absolute inset-0 opacity-[0.04]"
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.5) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.5) 1px, transparent 1px)",
          backgroundSize: "48px 48px",
        }}
      />

      <StatusBar />

      {/* Brand header */}
      <div className="relative z-10 px-6 pb-3 pt-2">
        <div className="flex items-start justify-between gap-4">
          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <div className="flex h-9 w-9 items-center justify-center rounded-[12px] bg-gradient-to-br from-[#e8d5b0] to-[#9a7b4f] text-[#1a1208] shadow-[0_8px_24px_rgba(196,165,116,0.35)]">
                <GraduationCap className="h-5 w-5" strokeWidth={2.2} />
              </div>
              <div className="min-w-0">
                <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[#c4a574]">
                  University of Los Santos
                </p>
                <h1
                  className="truncate text-[26px] font-semibold leading-none tracking-[-0.02em] text-[#f7f2ea]"
                  style={{ fontFamily: '"Iowan Old Style", Georgia, serif' }}
                >
                  Campus Portal
                </h1>
              </div>
            </div>
            <p className="mt-2 text-[12px] tracking-wide text-[#8b93a3]">
              Built by{" "}
              <span className="font-semibold text-[#e8d5b0]">Keydi.dev</span>
              {" · "}
              First Philippine FiveM university tablet portal
            </p>
          </div>

          <div className="shrink-0 rounded-2xl border border-white/10 bg-white/[0.04] px-3.5 py-2.5 text-right backdrop-blur-md">
            <p className="text-[10px] uppercase tracking-[0.16em] text-[#8b93a3]">Signed in</p>
            <p className="mt-0.5 max-w-[140px] truncate text-[14px] font-semibold text-[#f4efe6]">
              {name}
            </p>
            <div className="mt-1.5 inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-[11px] font-semibold"
              style={{ backgroundColor: `${meta.accent}22`, color: meta.accent }}
            >
              <BadgeCheck className="h-3 w-3" strokeWidth={2.4} />
              {meta.label}
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="mt-4 flex gap-1 rounded-2xl border border-white/8 bg-black/25 p-1">
          {tabs.map((t) => (
            <button
              key={t.id}
              type="button"
              onClick={() => setTab(t.id)}
              className={cn(
                "flex-1 rounded-xl px-2 py-2 text-[12px] font-semibold tracking-wide transition-all",
                tab === t.id
                  ? "bg-gradient-to-b from-[#e8d5b0] to-[#b8955f] text-[#1a1208] shadow-md"
                  : "text-[#9aa3b2] hover:bg-white/5 hover:text-[#f4efe6]",
              )}
              style={{ fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif' }}
            >
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {/* Body */}
      <div
        className="relative z-10 min-h-0 flex-1 overflow-y-auto px-6 pb-16"
        style={{ fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif' }}
      >
        {tab === "home" && (
          <div className="space-y-3">
            <div className="overflow-hidden rounded-[22px] border border-white/10 bg-gradient-to-br from-[#162033] to-[#0d1320] p-4 shadow-[0_16px_40px_rgba(0,0,0,0.35)]">
              <div className="flex items-center gap-2 text-[#c4a574]">
                <Sparkles className="h-4 w-4" />
                <span className="text-[11px] font-semibold uppercase tracking-[0.18em]">
                  Role workspace
                </span>
              </div>
              <p className="mt-2 text-[20px] font-semibold tracking-tight text-[#f7f2ea]">
                Welcome, {name.split(" ")[0]}
              </p>
              <p className="mt-1 text-[13px] leading-relaxed text-[#9aa3b2]">{meta.blurb}</p>

              <div className="mt-4 grid grid-cols-3 gap-2">
                <div className="rounded-2xl bg-white/[0.04] px-3 py-3">
                  <BookOpen className="h-4 w-4 text-[#c4a574]" />
                  <p className="mt-2 text-[18px] font-semibold text-white">{courses.length}</p>
                  <p className="text-[11px] text-[#8b93a3]">Courses</p>
                </div>
                <div className="rounded-2xl bg-white/[0.04] px-3 py-3">
                  <Users className="h-4 w-4 text-[#c4a574]" />
                  <p className="mt-2 text-[18px] font-semibold text-white">
                    {role === "student" ? enrolledIds.length : "128"}
                  </p>
                  <p className="text-[11px] text-[#8b93a3]">
                    {role === "student" ? "Enrolled" : "Students"}
                  </p>
                </div>
                <div className="rounded-2xl bg-white/[0.04] px-3 py-3">
                  <Landmark className="h-4 w-4 text-[#c4a574]" />
                  <p className="mt-2 text-[18px] font-semibold text-white">{COLLEGES.length}</p>
                  <p className="text-[11px] text-[#8b93a3]">Colleges</p>
                </div>
              </div>
            </div>

            {role === "visitor" && (
              <div className="rounded-[22px] border border-dashed border-[#c4a574]/35 bg-[#c4a574]/08 p-4">
                <p className="text-[15px] font-semibold text-[#f4efe6]">Not enrolled yet</p>
                <p className="mt-1 text-[13px] leading-relaxed text-[#9aa3b2]">
                  Visit the Director office or Registrar to get your Student ID. Until then, browse
                  campus and course catalogs as a guest.
                </p>
                <button
                  type="button"
                  onClick={() => setTab("campus")}
                  className="mt-3 inline-flex items-center gap-1.5 rounded-full bg-[#c4a574] px-4 py-2 text-[12px] font-semibold text-[#1a1208]"
                >
                  View campus map <ChevronRight className="h-3.5 w-3.5" />
                </button>
              </div>
            )}

            {role === "student" && (
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <p className="text-[12px] font-semibold uppercase tracking-[0.16em] text-[#8b93a3]">
                    My schedule
                  </p>
                  <button
                    type="button"
                    className="text-[12px] font-semibold text-[#c4a574]"
                    onClick={() => setTab("courses")}
                  >
                    Browse all
                  </button>
                </div>
                {courses
                  .filter((c) => enrolledIds.includes(c.id))
                  .map((c) => (
                    <div
                      key={c.id}
                      className="rounded-2xl border border-white/8 bg-white/[0.03] px-4 py-3"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <p className="text-[11px] font-semibold tracking-wide text-[#c4a574]">
                            {c.code}
                          </p>
                          <p className="text-[15px] font-semibold text-[#f4efe6]">{c.name}</p>
                          <p className="mt-1 flex items-center gap-1.5 text-[12px] text-[#8b93a3]">
                            <CalendarDays className="h-3.5 w-3.5" /> {c.schedule}
                          </p>
                        </div>
                        <IdCard className="h-5 w-5 shrink-0 text-[#6eb5ff]" />
                      </div>
                    </div>
                  ))}
              </div>
            )}

            {isStaff && (
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => setTab("courses")}
                  className="rounded-2xl border border-white/8 bg-white/[0.04] p-4 text-left transition-colors hover:bg-white/[0.07]"
                >
                  <ClipboardList className="h-5 w-5 text-[#7dd3a8]" />
                  <p className="mt-3 text-[14px] font-semibold text-white">Class roster</p>
                  <p className="mt-1 text-[12px] text-[#8b93a3]">Preview · live data soon</p>
                </button>
                <button
                  type="button"
                  onClick={() => flash("Announcements wire next pass")}
                  className="rounded-2xl border border-white/8 bg-white/[0.04] p-4 text-left transition-colors hover:bg-white/[0.07]"
                >
                  <Bell className="h-5 w-5 text-[#e8b86d]" />
                  <p className="mt-3 text-[14px] font-semibold text-white">Campus feed</p>
                  <p className="mt-1 text-[12px] text-[#8b93a3]">Broadcast to students</p>
                </button>
              </div>
            )}
          </div>
        )}

        {tab === "courses" && (
          <div className="space-y-3">
            <div className="flex gap-2">
              <div className="relative min-w-0 flex-1">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[#8b93a3]" />
                <input
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  placeholder="Search courses, codes, colleges…"
                  className="w-full rounded-2xl border border-white/10 bg-black/30 py-2.5 pl-10 pr-3 text-[13px] text-white outline-none placeholder:text-[#6b7383] focus:border-[#c4a574]/50"
                />
              </div>
            </div>

            <div className="flex gap-1.5 overflow-x-auto pb-1">
              {["All", ...COLLEGES].map((col) => (
                <button
                  key={col}
                  type="button"
                  onClick={() => setCollegeFilter(col)}
                  className={cn(
                    "shrink-0 rounded-full px-3 py-1.5 text-[11px] font-semibold transition-colors",
                    collegeFilter === col
                      ? "bg-[#c4a574] text-[#1a1208]"
                      : "bg-white/5 text-[#9aa3b2] hover:bg-white/10",
                  )}
                >
                  {col === "All" ? "All colleges" : col.replace("College of ", "")}
                </button>
              ))}
            </div>

            {filtered.map((c) => {
              const mine = enrolledIds.includes(c.id);
              return (
                <div
                  key={c.id}
                  className="rounded-[20px] border border-white/8 bg-gradient-to-br from-white/[0.05] to-transparent p-4"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-[11px] font-bold tracking-[0.14em] text-[#c4a574]">
                        {c.code}
                      </p>
                      <p className="mt-0.5 text-[16px] font-semibold leading-snug text-[#f7f2ea]">
                        {c.name}
                      </p>
                      <p className="mt-1 text-[12px] text-[#8b93a3]">{c.college}</p>
                    </div>
                    {mine && (
                      <span className="rounded-full bg-[#6eb5ff]/15 px-2 py-1 text-[10px] font-bold uppercase tracking-wide text-[#6eb5ff]">
                        Enrolled
                      </span>
                    )}
                  </div>
                  <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 text-[12px] text-[#9aa3b2]">
                    <span className="inline-flex items-center gap-1">
                      <CalendarDays className="h-3.5 w-3.5" /> {c.schedule}
                    </span>
                    <span className="inline-flex items-center gap-1">
                      <MapPin className="h-3.5 w-3.5" /> {c.room}
                    </span>
                  </div>
                  <SeatBar enrolled={c.enrolled} seats={c.seats} />
                  {role === "student" && (
                    <button
                      type="button"
                      className={cn(
                        "mt-3 w-full rounded-xl py-2.5 text-[13px] font-semibold transition-transform active:scale-[0.99]",
                        mine
                          ? "border border-white/15 bg-transparent text-[#9aa3b2]"
                          : "bg-gradient-to-r from-[#e8d5b0] to-[#b8955f] text-[#1a1208]",
                      )}
                      onClick={() => {
                        if (mine) {
                          setEnrolledIds((ids) => ids.filter((id) => id !== c.id));
                          setCourses((prev) =>
                            prev.map((x) =>
                              x.id === c.id
                                ? { ...x, enrolled: Math.max(0, x.enrolled - 1) }
                                : x,
                            ),
                          );
                          flash("Dropped course");
                        } else {
                          setEnrolledIds((ids) => [...ids, c.id]);
                          setCourses((prev) =>
                            prev.map((x) =>
                              x.id === c.id ? { ...x, enrolled: x.enrolled + 1 } : x,
                            ),
                          );
                          flash("Enrolled · Keydi.dev");
                        }
                      }}
                    >
                      {mine ? "Drop course" : "Enroll"}
                    </button>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {tab === "campus" && (
          <div className="space-y-3">
            <div className="rounded-[22px] border border-white/10 bg-[#121a2a] p-4">
              <div className="flex items-center gap-2 text-[#c4a574]">
                <Building2 className="h-4 w-4" />
                <span className="text-[11px] font-semibold uppercase tracking-[0.16em]">
                  Campus directory
                </span>
              </div>
              <p className="mt-2 text-[15px] leading-relaxed text-[#c8d0dc]">
                Main Campus · Blip on map · Director office, classrooms, lockers, shops, and
                whiteboards live in-world.
              </p>
            </div>

            {[
              { title: "Director Office", desc: "Enrollment · faculty · announcements", icon: Landmark },
              { title: "Language Wings", desc: "Italian · Spanish · Japanese · Russian", icon: BookOpen },
              { title: "Science Block", desc: "Chemistry lab · clinics", icon: Sparkles },
              { title: "Student Services", desc: "Lockers · backpack shop · printers", icon: IdCard },
            ].map((item) => (
              <div
                key={item.title}
                className="flex items-center gap-3 rounded-2xl border border-white/8 bg-white/[0.03] px-4 py-3.5"
              >
                <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#c4a574]/12 text-[#c4a574]">
                  <item.icon className="h-5 w-5" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-[14px] font-semibold text-[#f4efe6]">{item.title}</p>
                  <p className="text-[12px] text-[#8b93a3]">{item.desc}</p>
                </div>
                <ChevronRight className="h-4 w-4 text-[#5c6575]" />
              </div>
            ))}
          </div>
        )}

        {tab === "admin" && isAdmin && (
          <div className="space-y-3">
            <div className="rounded-[22px] border border-[#c4a574]/25 bg-gradient-to-br from-[#2a2114] to-[#121820] p-4">
              <div className="flex items-center justify-between gap-2">
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#e8d5b0]">
                    Enrollment queue
                  </p>
                  <p className="mt-1 text-[12px] text-[#9aa3b2]">
                    Approve Registrar applications · live from database
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => void loadPending()}
                  className="rounded-full border border-white/10 px-3 py-1.5 text-[11px] font-semibold text-[#c4a574] hover:bg-white/5"
                >
                  {pendingLoading ? "Loading…" : "Refresh"}
                </button>
              </div>

              <div className="mt-3 space-y-2">
                {pendingApps.length === 0 && (
                  <p className="rounded-xl border border-dashed border-white/10 px-3 py-4 text-center text-[12px] text-[#8b93a3]">
                    No pending applications
                  </p>
                )}
                {pendingApps.map((app) => (
                  <div
                    key={app.id}
                    className="rounded-2xl border border-white/10 bg-black/25 px-3.5 py-3"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div className="min-w-0">
                        <p className="truncate text-[14px] font-semibold text-white">
                          {app.citizenName || "Applicant"}
                        </p>
                        <p className="mt-0.5 text-[12px] text-[#c4a574]">
                          {app.programCode} · {app.programLabel}
                        </p>
                        {app.createdAt && (
                          <p className="mt-1 text-[11px] text-[#8b93a3]">{app.createdAt}</p>
                        )}
                      </div>
                    </div>
                    <div className="mt-3 flex gap-2">
                      <button
                        type="button"
                        onClick={() => void reviewApp(app.id, "approve")}
                        className="flex-1 rounded-xl bg-gradient-to-r from-[#e8d5b0] to-[#b8955f] py-2 text-[12px] font-bold text-[#1a1208]"
                      >
                        Approve
                      </button>
                      <button
                        type="button"
                        onClick={() => void reviewApp(app.id, "deny")}
                        className="flex-1 rounded-xl border border-red-400/30 bg-red-500/10 py-2 text-[12px] font-semibold text-red-300"
                      >
                        Deny
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="rounded-[22px] border border-white/8 bg-white/[0.03] p-4">
              <div className="flex items-center gap-2">
                <Plus className="h-4 w-4 text-[#e8d5b0]" />
                <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#e8d5b0]">
                  Create college course
                </p>
              </div>
              <div className="mt-3 space-y-2">
                <input
                  value={draftCode}
                  onChange={(e) => setDraftCode(e.target.value)}
                  placeholder="Course code · e.g. BSIT-220"
                  className="w-full rounded-xl border border-white/10 bg-black/35 px-3 py-2.5 text-[13px] text-white outline-none placeholder:text-[#6b7383] focus:border-[#c4a574]/45"
                />
                <input
                  value={draftName}
                  onChange={(e) => setDraftName(e.target.value)}
                  placeholder="Course title"
                  className="w-full rounded-xl border border-white/10 bg-black/35 px-3 py-2.5 text-[13px] text-white outline-none placeholder:text-[#6b7383] focus:border-[#c4a574]/45"
                />
                <select
                  value={draftCollege}
                  onChange={(e) => setDraftCollege(e.target.value)}
                  className="w-full rounded-xl border border-white/10 bg-black/35 px-3 py-2.5 text-[13px] text-white outline-none focus:border-[#c4a574]/45"
                >
                  {COLLEGES.map((c) => (
                    <option key={c} value={c} className="bg-[#121820]">
                      {c}
                    </option>
                  ))}
                </select>
                <button
                  type="button"
                  onClick={createCourse}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-[#e8d5b0] to-[#b8955f] py-3 text-[13px] font-bold text-[#1a1208]"
                >
                  <Plus className="h-4 w-4" strokeWidth={2.4} />
                  Publish course
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Footer brand */}
      <div className="pointer-events-none absolute bottom-9 left-0 right-0 z-20 flex justify-center">
        <p className="rounded-full border border-white/10 bg-black/40 px-3 py-1 text-[10px] font-semibold tracking-[0.2em] text-[#c4a574]/90 backdrop-blur-md">
          KEYDI.DEV · ULS PORTAL
        </p>
      </div>

      {toast && (
        <div className="absolute bottom-16 left-1/2 z-50 -translate-x-1/2 rounded-full bg-[#f4efe6] px-4 py-2 text-[12px] font-semibold text-[#1a1208] shadow-xl">
          {toast}
        </div>
      )}
    </div>
  );
}
