import React, { useState, useEffect, useLayoutEffect, useRef, useMemo, useCallback, memo } from "react";

interface Message {
  template?: string;
  templateId?: string;
  args?: string[];
  color?: [number, number, number];
  multiline?: boolean;
}

interface StoredMessage extends Message {
  id: number;
  html: string;
}

interface SuggestionParam {
  name: string;
  help?: string;
  disabled?: boolean;
}

interface Suggestion {
  name: string;
  help?: string;
  params?: SuggestionParam[];
  disabled?: boolean;
}

const DEFAULT_TEMPLATES: Record<string, string> = {
  default: '<div style="background: rgba(15, 10, 25, 0.85); border-radius: 6px; padding: 8px 10px; margin-bottom: 6px; border-left: 3px solid rgba(255, 30, 30, 0.7); text-align: left; font-family: sans-serif;"><b style="color: #ff4d4d;">{0}</b>: <span style="color: #ffffff;">{1}</span></div>',
  defaultAlt: "{0}",
  print: "<pre style='text-align: left; font-family: monospace; font-size: 13px;'>{0}</pre>",
  "example:important": "<h1 style='text-align: left;'>^2{0}</h1>"
};

const MAX_MESSAGES = 80;

function escapeHtml(unsafe: string): string {
  return String(unsafe)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function colorizeOld(str: string, color: [number, number, number]): string {
  return `<span style="color: rgb(${color[0]}, ${color[1]}, ${color[2]})">${str}</span>`;
}

function colorize(str: string): string {
  const colorMap: Record<string, string> = {
    "0": "#ffffff",
    "1": "#ff4d4d",
    "2": "#2ecc71",
    "3": "#f1c40f",
    "4": "#3498db",
    "5": "#00d2d3",
    "6": "#9b59b6",
    "7": "#ffffff",
    "8": "#e74c3c",
    "9": "#ff7979"
  };

  let s = "<span>" + str.replace(/\^([0-9])/g, (_, colorNum) => {
    const hex = colorMap[colorNum] || "#ffffff";
    return `</span><span style="color: ${hex}">`;
  }) + "</span>";

  const styleDict: Record<string, string> = {
    "*": "font-weight: bold;",
    "_": "text-decoration: underline;",
    "~": "text-decoration: line-through;",
    "=": "text-decoration: underline line-through;",
    "r": "text-decoration: none; font-weight: normal; font-style: normal;"
  };

  const styleRegex = /\^([_*~=r])(.*?)(?=$|\^r|<\/em>)/;
  while (s.match(styleRegex)) {
    s = s.replace(styleRegex, (_, styleCode, inner) => {
      const style = styleDict[styleCode] || "";
      return `<em style="${style}">${inner}</em>`;
    });
  }

  return s.replace(/<span[^>]*><\/span[^>]*>/g, "");
}

function formatMessage(msg: Message, templates: Record<string, string>): string {
  let templateStr = msg.template ? msg.template : (templates[msg.templateId || "default"] || "{0}: {1}");

  if (!msg.template && (!msg.templateId || msg.templateId === "default") && msg.args && msg.args.length === 1) {
    templateStr = templates["defaultAlt"] || "{0}";
  }

  const args = msg.args || [];
  templateStr = templateStr.replace(/{(\d+)}/g, (match, numberStr) => {
    const number = parseInt(numberStr, 10);
    let argEscaped = args[number] !== undefined ? escapeHtml(args[number]) : match;
    if (number === 0 && msg.color) {
      argEscaped = colorizeOld(argEscaped, msg.color);
    }
    return argEscaped;
  });

  return colorize(templateStr);
}

const MessageRow = memo(function MessageRow({ html }: { html: string }) {
  return (
    <div
      className="text-[12px] leading-normal break-words font-medium antialiased text-white [text-shadow:_0_1px_4px_rgba(0,0,0,0.9)] text-left"
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
});

function getResourceName(): string {
  return (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : "kodebykarl-ui";
}

export default function Chat() {
  const [isOpen, setIsOpen] = useState(false);
  const [showWindow, setShowWindow] = useState(false);
  const [shouldHide, setShouldHide] = useState(false);
  const [inputValue, setInputValue] = useState("");
  const [messages, setMessages] = useState<StoredMessage[]>([]);
  const [templates, setTemplates] = useState<Record<string, string>>(DEFAULT_TEMPLATES);
  const [allSuggestions, setAllSuggestions] = useState<Suggestion[]>([]);
  const [removedSuggestions, setRemovedSuggestions] = useState<string[]>([]);
  const [fadeTimeout, setFadeTimeout] = useState(10000);

  const [history, setHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);

  const inputRef = useRef<HTMLInputElement>(null);
  const openListRef = useRef<HTMLDivElement>(null);
  const overlayListRef = useRef<HTMLDivElement>(null);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isOpenRef = useRef(false);
  const fadeTimeoutRef = useRef(10000);
  const templatesRef = useRef(templates);
  const msgIdRef = useRef(0);
  const resetShowWindowTimerRef = useRef<() => void>(() => {});

  useEffect(() => {
    isOpenRef.current = isOpen;
  }, [isOpen]);

  useEffect(() => {
    fadeTimeoutRef.current = fadeTimeout;
  }, [fadeTimeout]);

  useEffect(() => {
    templatesRef.current = templates;
  }, [templates]);

  const resetShowWindowTimer = useCallback(() => {
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }
    setShowWindow(true);
    timerRef.current = setTimeout(() => {
      if (!isOpenRef.current) {
        setShowWindow(false);
      }
    }, fadeTimeoutRef.current);
  }, []);

  useEffect(() => {
    resetShowWindowTimerRef.current = resetShowWindowTimer;
  }, [resetShowWindowTimer]);

  const scrollMessagesToBottom = useCallback(() => {
    const els = [openListRef.current, overlayListRef.current];
    for (let i = 0; i < els.length; i++) {
      const el = els[i];
      if (!el) continue;
      el.scrollTop = el.scrollHeight;
    }
  }, []);

  useLayoutEffect(() => {
    scrollMessagesToBottom();
  }, [messages, showWindow, isOpen, scrollMessagesToBottom]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const item = event.data;
      if (!item || typeof item.type !== "string") return;

      switch (item.type) {
        case "ON_CHAT_CONFIG":
          if (typeof item.fadeTimeout === "number" && item.fadeTimeout > 0) {
            setFadeTimeout(item.fadeTimeout);
            fadeTimeoutRef.current = item.fadeTimeout;
          }
          break;

        case "ON_OPEN":
          isOpenRef.current = true;
          setIsOpen(true);
          setShowWindow(true);
          if (timerRef.current) {
            clearTimeout(timerRef.current);
            timerRef.current = null;
          }
          break;

        case "ON_MESSAGE": {
          const raw = item.message as Message;
          const id = ++msgIdRef.current;
          const html = formatMessage(raw || {}, templatesRef.current);
          setMessages((prev) => {
            const next = [...prev, { ...(raw || {}), id, html }];
            return next.length > MAX_MESSAGES ? next.slice(next.length - MAX_MESSAGES) : next;
          });
          resetShowWindowTimerRef.current();
          break;
        }

        case "ON_CLEAR":
          setMessages([]);
          setHistory([]);
          setHistoryIndex(-1);
          setShowWindow(false);
          if (timerRef.current) {
            clearTimeout(timerRef.current);
            timerRef.current = null;
          }
          break;

        case "ON_SUGGESTION_ADD": {
          const sug = item.suggestion as Suggestion;
          setAllSuggestions((prev) => {
            const idx = prev.findIndex((a) => a.name === sug.name);
            if (idx !== -1) {
              const copy = prev.slice();
              const exists = { ...copy[idx] };
              if (sug.help && sug.help.trim() !== "") {
                exists.help = sug.help;
              }
              if (sug.params && sug.params.length > 0) {
                exists.params = sug.params;
              }
              copy[idx] = exists;
              return copy;
            }
            return [...prev, { ...sug, params: sug.params || [] }];
          });
          setRemovedSuggestions((prev) => prev.filter((name) => name !== sug.name));
          break;
        }

        case "ON_SUGGESTION_REMOVE":
          setRemovedSuggestions((prev) => (prev.includes(item.name) ? prev : [...prev, item.name]));
          break;

        case "ON_COMMANDS_RESET":
          setAllSuggestions([]);
          setRemovedSuggestions([]);
          break;

        case "ON_TEMPLATE_ADD": {
          const tpl = item.template;
          setTemplates((prev) => ({
            ...prev,
            [tpl.id]: tpl.html
          }));
          break;
        }

        case "ON_SCREEN_STATE_CHANGE":
          setShouldHide(!!item.shouldHide);
          break;

        default:
          break;
      }
    };

    window.addEventListener("message", handleMessage);

    fetch(`https://${getResourceName()}/chatLoaded`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    }).catch(() => {});

    return () => {
      window.removeEventListener("message", handleMessage);
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, []);

  useEffect(() => {
    if (!isOpen) return;
    const focusTimer = window.setTimeout(() => {
      inputRef.current?.focus();
    }, 30);
    return () => window.clearTimeout(focusTimer);
  }, [isOpen]);

  const formattedSuggestions = useMemo(() => {
    const raw = inputValue.trim();
    if (!raw.startsWith("/")) return [];

    const normalizedMessage = raw;
    const removed = new Set(removedSuggestions);

    const matched: Suggestion[] = [];
    for (let i = 0; i < allSuggestions.length; i++) {
      const s = allSuggestions[i];
      if (removed.has(s.name)) continue;

      let ok = false;
      if (s.name.startsWith(normalizedMessage)) {
        ok = true;
      } else {
        const suggestionSplitted = s.name.split(" ");
        const messageSplitted = normalizedMessage.split(" ");
        ok = true;
        for (let j = 0; j < messageSplitted.length; j++) {
          if (j >= suggestionSplitted.length) {
            ok = j < suggestionSplitted.length + (s.params || []).length;
            break;
          }
          if (suggestionSplitted[j] !== messageSplitted[j]) {
            ok = false;
            break;
          }
        }
      }

      if (!ok) continue;

      const disabled = !s.name.startsWith(normalizedMessage);
      const params = s.params || [];
      const formattedParams = params.map((p, index) => {
        const wType = index === params.length - 1 ? "." : "\\S";
        const escapedName = s.name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        const regex = new RegExp(`${escapedName} (?:\\S+ ){${index}}(?:${wType}*)$`, "g");
        return {
          ...p,
          disabled: inputValue.match(regex) == null
        };
      });

      matched.push({ ...s, disabled, params: formattedParams });
      if (matched.length >= 5) break;
    }

    return matched;
  }, [inputValue, allSuggestions, removedSuggestions]);

  const closeChatAndScheduleHide = useCallback(() => {
    isOpenRef.current = false;
    setIsOpen(false);
    resetShowWindowTimer();
  }, [resetShowWindowTimer]);

  const sendSubmit = () => {
    const resourceName = getResourceName();

    if (inputValue.trim() !== "") {
      fetch(`https://${resourceName}/chatResult`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: inputValue })
      }).catch(() => {});

      setHistory((prev) => [inputValue, ...prev]);
      setHistoryIndex(-1);
    } else {
      fetch(`https://${resourceName}/chatResult`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ canceled: true })
      }).catch(() => {});
    }

    setInputValue("");
    closeChatAndScheduleHide();
  };

  const cancelSubmit = () => {
    fetch(`https://${getResourceName()}/chatResult`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ canceled: true })
    }).catch(() => {});

    setInputValue("");
    closeChatAndScheduleHide();
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      e.preventDefault();
      sendSubmit();
    } else if (e.key === "Escape") {
      e.preventDefault();
      cancelSubmit();
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      if (history.length > 0 && historyIndex + 1 < history.length) {
        const nextIdx = historyIndex + 1;
        setHistoryIndex(nextIdx);
        setInputValue(history[nextIdx]);
      }
    } else if (e.key === "ArrowDown") {
      e.preventDefault();
      if (historyIndex - 1 >= 0) {
        const nextIdx = historyIndex - 1;
        setHistoryIndex(nextIdx);
        setInputValue(history[nextIdx]);
      } else if (historyIndex - 1 === -1) {
        setHistoryIndex(-1);
        setInputValue("");
      }
    }
  };

  const selectSuggestion = (s: Suggestion) => {
    setInputValue(s.name + " ");
    inputRef.current?.focus();
  };

  const onInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValue(e.target.value);
  };

  if (shouldHide) return null;

  const messageNodes = messages.map((msg) => (
    <MessageRow key={msg.id} html={msg.html} />
  ));

  return (
    <>
      {/* Full Chat Console (when typing) */}
      <div className={`grim-chat-container ${isOpen ? "open" : "closed"}`}>
        <div className="grim-chat-header">
          <div className="grim-chat-title">
            <span className="grim-chat-title-badge">GRIM</span>
            <span>CHAT</span>
          </div>
          <span className="grim-chat-subtitle">
            Enter send &bull; Esc close
          </span>
        </div>

        <div ref={openListRef} className="grim-chat-messages">
          {isOpen ? messageNodes : null}
        </div>

        <div className="grim-chat-input-wrapper">
          <input
            ref={inputRef}
            type="text"
            className="grim-chat-input"
            placeholder="Type a command (e.g. /staff, /sf)..."
            value={inputValue}
            onChange={onInputChange}
            onKeyDown={handleKeyDown}
            autoComplete="off"
            spellCheck={false}
          />
          <button
            type="button"
            onClick={sendSubmit}
            className="grim-chat-send-btn"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth={2.5}
              stroke="currentColor"
              style={{ width: 16, height: 16 }}
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
            </svg>
          </button>
        </div>

        {isOpen && formattedSuggestions.length > 0 && (
          <div className="grim-chat-suggestions">
            {formattedSuggestions.map((s) => (
              <button
                key={s.name}
                type="button"
                onClick={() => selectSuggestion(s)}
                className="grim-suggestion-item"
              >
                <div>
                  <span className="grim-suggestion-name">{s.name}</span>
                  {s.params && s.params.map((p, pIdx) => (
                    <span key={`${s.name}-${p.name}-${pIdx}`} className="grim-suggestion-param">
                      [{p.name}]
                    </span>
                  ))}
                </div>
                {s.help && <span className="grim-suggestion-help">{s.help}</span>}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Overlay when chat is closed */}
      {!isOpen && showWindow && (
        <div className="grim-chat-overlay">
          <div ref={overlayListRef} className="grim-chat-messages" style={{ height: "auto", maxHeight: 380 }}>
            {messageNodes}
          </div>
        </div>
      )}
    </>
  );
}
