(() => {
  const DEFAULTS = {
    serverName: "Grim City",
    music: {
      youtubeId: "k5ri3jyGPNQ",
      title: "Loading Theme",
      artist: "Grim City",
    },
    staff: {
      owner: [],
      developer: [],
      gods: [],
      city_management: [],
    },
    roleOrder: ["owner", "developer", "gods", "city_management"],
    roles: {
      owner: "Owner",
      developer: "Developer",
      gods: "Gods",
      city_management: "City Management",
    },
  };

  const handover = window.nuiHandoverData || {};
  const musicCfg = Object.assign({}, DEFAULTS.music, handover.music || {});
  const roleLabels = Object.assign({}, DEFAULTS.roles, handover.roles || {});
  const roleOrder =
    Array.isArray(handover.roleOrder) && handover.roleOrder.length
      ? handover.roleOrder
      : DEFAULTS.roleOrder;
  const staffData = Object.assign({}, DEFAULTS.staff, handover.staff || {});

  const els = {
    trackTitle: document.getElementById("trackTitle"),
    trackArtist: document.getElementById("trackArtist"),
    musicFill: document.getElementById("musicFill"),
    musicTime: document.getElementById("musicTime"),
    musicDuration: document.getElementById("musicDuration"),
    btnPlay: document.getElementById("btnPlay"),
    btnStop: document.getElementById("btnStop"),
    btnMute: document.getElementById("btnMute"),
    iconPlay: document.getElementById("iconPlay"),
    iconPause: document.getElementById("iconPause"),
    iconVol: document.getElementById("iconVol"),
    iconMute: document.getElementById("iconMute"),
    loadFill: document.getElementById("loadFill"),
    loadLabel: document.getElementById("loadLabel"),
    sidebarKey: document.getElementById("sidebarKey"),
    sidebar: document.getElementById("staffSidebar"),
    sidebarClose: document.getElementById("sidebarClose"),
    sidebarBackdrop: document.getElementById("sidebarBackdrop"),
    staffList: document.getElementById("staffList"),
    staffEmpty: document.getElementById("staffEmpty"),
  };

  els.trackTitle.textContent = musicCfg.title || DEFAULTS.music.title;
  els.trackArtist.textContent = musicCfg.artist || DEFAULTS.music.artist;

  /* ---------- load progress ---------- */
  window.addEventListener("message", (event) => {
    const data = event.data || {};
    if (data.eventName === "loadProgress") {
      const pct = Math.max(0, Math.min(1, Number(data.loadFraction) || 0));
      const shown = Math.round(pct * 100);
      els.loadFill.style.width = `${shown}%`;
      els.loadLabel.textContent = `${shown}%`;
    }
  });

  /* ---------- staff sidebar (single list, role on each card) ---------- */
  let sidebarOpen = false;

  function setSidebarOpen(open) {
    sidebarOpen = open;
    els.sidebar.classList.toggle("is-open", open);
    els.sidebarKey.classList.toggle("is-open", open);
    els.sidebar.setAttribute("aria-hidden", open ? "false" : "true");
    els.sidebarKey.setAttribute("aria-expanded", open ? "true" : "false");
    if (els.sidebarBackdrop) {
      els.sidebarBackdrop.hidden = false;
      els.sidebarBackdrop.classList.toggle("is-visible", open);
      if (!open) {
        setTimeout(() => {
          if (!sidebarOpen) els.sidebarBackdrop.hidden = true;
        }, 300);
      }
    }
  }

  function collectAllStaff() {
    const seen = new Set();
    const list = [];

    roleOrder.forEach((key) => {
      const roleLabel = roleLabels[key] || key;
      (staffData[key] || []).forEach((m) => {
        const id = String(m.id || m.name || "");
        // Prefer highest-priority role (first in roleOrder) if someone has multiple
        if (id && seen.has(id)) return;
        if (id) seen.add(id);
        list.push({
          id,
          name: m.name || "Unknown",
          avatar: m.avatar || "",
          role: roleLabel,
        });
      });
    });

    return list;
  }

  function renderStaff() {
    const members = collectAllStaff();
    els.staffList.innerHTML = "";

    if (!members.length) {
      els.staffEmpty.textContent = "No staff listed yet.";
      els.staffEmpty.classList.remove("is-hidden");
      return;
    }

    els.staffEmpty.classList.add("is-hidden");

    members.forEach((m) => {
      const row = document.createElement("article");
      row.className = "staff-row";
      row.innerHTML = `
        <img src="${m.avatar}" alt="" loading="lazy" onerror="this.src='https://cdn.discordapp.com/embed/avatars/0.png'" />
        <div class="staff-row__meta">
          <span class="staff-row__name"></span>
          <span class="staff-row__role"></span>
        </div>
      `;
      row.querySelector(".staff-row__name").textContent = m.name;
      row.querySelector(".staff-row__role").textContent = m.role;
      els.staffList.appendChild(row);
    });
  }

  els.sidebarKey.addEventListener("click", () => setSidebarOpen(!sidebarOpen));
  els.sidebarClose.addEventListener("click", () => setSidebarOpen(false));
  if (els.sidebarBackdrop) {
    els.sidebarBackdrop.addEventListener("click", () => setSidebarOpen(false));
  }

  renderStaff();

  /* ---------- YouTube player ---------- */
  let ytPlayer = null;
  let playing = false;
  let muted = false;
  let progressTimer = null;

  function fmt(sec) {
    sec = Math.max(0, Math.floor(sec || 0));
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${m}:${s.toString().padStart(2, "0")}`;
  }

  function setPlayingUi(isPlaying) {
    playing = isPlaying;
    els.iconPlay.classList.toggle("is-hidden", isPlaying);
    els.iconPause.classList.toggle("is-hidden", !isPlaying);
  }

  function setMuteUi(isMuted) {
    muted = isMuted;
    els.iconVol.classList.toggle("is-hidden", isMuted);
    els.iconMute.classList.toggle("is-hidden", !isMuted);
  }

  function tickProgress() {
    if (!ytPlayer || typeof ytPlayer.getCurrentTime !== "function") return;
    try {
      const cur = ytPlayer.getCurrentTime() || 0;
      const dur = ytPlayer.getDuration() || 0;
      const pct = dur > 0 ? (cur / dur) * 100 : 0;
      els.musicFill.style.width = `${pct}%`;
      els.musicTime.textContent = fmt(cur);
      els.musicDuration.textContent = fmt(dur);
    } catch (_) {
      /* ignore */
    }
  }

  function startProgress() {
    stopProgress();
    progressTimer = setInterval(tickProgress, 400);
  }

  function stopProgress() {
    if (progressTimer) {
      clearInterval(progressTimer);
      progressTimer = null;
    }
  }

  window.onYouTubeIframeAPIReady = function onYouTubeIframeAPIReady() {
    ytPlayer = new YT.Player("ytHost", {
      height: "1",
      width: "1",
      videoId: musicCfg.youtubeId || DEFAULTS.music.youtubeId,
      playerVars: {
        autoplay: 1,
        controls: 0,
        disablekb: 1,
        fs: 0,
        modestbranding: 1,
        playsinline: 1,
        rel: 0,
        loop: 1,
        playlist: musicCfg.youtubeId || DEFAULTS.music.youtubeId,
      },
      events: {
        onReady: (e) => {
          try {
            e.target.setVolume(60);
            e.target.unMute();
            e.target.playVideo();
            setMuteUi(false);
            setPlayingUi(true);
            startProgress();
          } catch (_) {
            /* CEF may block autoplay; user can press play */
            setPlayingUi(false);
          }
        },
        onStateChange: (e) => {
          if (e.data === YT.PlayerState.PLAYING) {
            setPlayingUi(true);
            startProgress();
          } else if (e.data === YT.PlayerState.PAUSED) {
            setPlayingUi(false);
          } else if (e.data === YT.PlayerState.ENDED) {
            setPlayingUi(false);
            try {
              e.target.seekTo(0);
              e.target.playVideo();
            } catch (_) {}
          }
        },
        onError: () => {
          setPlayingUi(false);
          els.trackArtist.textContent = "Music unavailable in this client";
        },
      },
    });
  };

  // If API already loaded (cached), fire manually
  if (window.YT && window.YT.Player) {
    window.onYouTubeIframeAPIReady();
  }

  els.btnPlay.addEventListener("click", () => {
    if (!ytPlayer) return;
    if (playing) {
      ytPlayer.pauseVideo();
      setPlayingUi(false);
    } else {
      ytPlayer.playVideo();
      setPlayingUi(true);
    }
  });

  els.btnStop.addEventListener("click", () => {
    if (!ytPlayer) return;
    try {
      ytPlayer.pauseVideo();
      ytPlayer.seekTo(0);
    } catch (_) {}
    setPlayingUi(false);
    els.musicFill.style.width = "0%";
    els.musicTime.textContent = "0:00";
  });

  els.btnMute.addEventListener("click", () => {
    if (!ytPlayer) return;
    if (muted) {
      ytPlayer.unMute();
      setMuteUi(false);
    } else {
      ytPlayer.mute();
      setMuteUi(true);
    }
  });
})();
