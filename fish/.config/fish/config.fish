# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Great Sage Interactive Shell (config.fish)
# ══════════════════════════════════════════════════════════════════════════════

if status is-interactive
    # ─── Great Sage System Greeting ───────────────────────────────────────────
    function fish_greeting
        set_color 00e5ff
        echo -n "◈ « Report. "
        set_color ffd54f
        echo -n "Unique Skill [Great Sage]"
        set_color 00e5ff
        echo " online. Magicule circuits nominal. »"
        set_color normal
    end

    # ─── Great Sage Syntax Highlighting ───────────────────────────────────────
    set -g fish_color_normal e2f1ff
    set -g fish_color_command 00e5ff --bold
    set -g fish_color_param 82b1ff
    set -g fish_color_quote ffd54f
    set -g fish_color_redirection b388ff
    set -g fish_color_end 00e5ff
    set -g fish_color_error ff5252 --bold
    set -g fish_color_comment 4a608a
    set -g fish_color_autosuggestion 3b4d71

    # ─── Geometric Diamond Prompt (Fallback if Starship is not installed) ─────
    if command -q starship
        starship init fish | source
    else
        function fish_prompt
            set -l last_status $status
            set_color 2979ff
            echo -n "╭─["
            set_color 00e5ff --bold
            echo -n (prompt_pwd)
            set_color 2979ff
            echo -n "]"

            if git rev-parse --is-inside-work-tree >/dev/null 2>&1
                set -l branch (git branch --show-current 2>/dev/null)
                set_color b388ff
                echo -n " ◈ $branch"
            end
            echo ""

            set_color 2979ff
            echo -n "╰─"
            if test $last_status -eq 0
                set_color ffd54f --bold
                echo -n "◈ "
            else
                set_color ff5252 --bold
                echo -n "◈ [$last_status] "
            end
            set_color normal
        end
    end

    # ─── Useful Aliases (CachyOS / Arch & HyprSlime) ──────────────────────────
    alias sage="$HOME/.config/hypr/scripts/great-sage-menu.sh"
    alias hyprreload="hyprctl reload"
    alias ll="ls -lah --color=auto"
end

