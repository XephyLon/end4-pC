/*
 * end4-pC Discord Voice companion for Vencord
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import definePlugin, { PluginNative } from "@utils/types";
import { findByPropsLazy } from "@webpack";
import { ChannelRTCStore, ChannelStore, GuildMemberStore, SelectedChannelStore, UserStore, VoiceStateStore } from "@webpack/common";

const Native = VencordNative.pluginHelpers.End4DiscordVoice as PluginNative<typeof import("./native")>;
const AudioActions = findByPropsLazy("toggleSelfMute", "toggleSelfDeaf");

let timer: ReturnType<typeof setInterval> | undefined;
let publishing = false;

function participant(userId: string, state: any, guildId?: string) {
    const user = UserStore.getUser(userId);
    if (!user) return null;
    return {
        id: user.id,
        username: user.username,
        nick: (guildId && GuildMemberStore.getNick(guildId, user.id)) || user.globalName || user.username,
        avatar: user.avatar || "",
        mute: Boolean(state.mute || state.selfMute),
        deaf: Boolean(state.deaf || state.selfDeaf),
        speaking: Boolean(state.speaking)
    };
}

function snapshot() {
    const channelId = SelectedChannelStore.getVoiceChannelId();
    const channel = channelId ? ChannelStore.getChannel(channelId) : null;
    const states = channelId ? VoiceStateStore.getVoiceStatesForChannel(channelId) || {} : {};
    const speakingIds = new Set(channelId
        ? ChannelRTCStore.getSpeakingParticipants(channelId).map(participant => participant.user.id)
        : []);
    const users = Object.entries(states)
        .map(([userId, state]) => {
            const normalized = { ...(state as object), speaking: speakingIds.has(userId) };
            return participant(userId, normalized, channel?.guild_id);
        })
        .filter(Boolean);
    const currentUser = UserStore.getCurrentUser();
    const ownState = currentUser ? VoiceStateStore.getVoiceStateForUser(currentUser.id) : null;
    return {
        version: 1,
        backend: "vencord",
        timestamp: Date.now(),
        user: currentUser ? {
            id: currentUser.id,
            username: currentUser.username,
            avatar: currentUser.avatar || ""
        } : null,
        channel: channel ? { id: channel.id, name: channel.name || "Voice channel", guild_id: channel.guild_id || "" } : null,
        users,
        mute: Boolean(ownState?.mute || ownState?.selfMute),
        deaf: Boolean(ownState?.deaf || ownState?.selfDeaf)
    };
}

async function applyCommands() {
    const raw = await Native.readCommands();
    for (const line of raw.split("\n")) {
        if (!line.trim()) continue;
        try {
            const command = JSON.parse(line);
            const state = snapshot();
            if (typeof command.mute === "boolean" && command.mute !== state.mute)
                AudioActions.toggleSelfMute();
            if (typeof command.deaf === "boolean" && command.deaf !== state.deaf)
                AudioActions.toggleSelfDeaf();
        } catch { /* Ignore partial or obsolete command lines. */ }
    }
}

// Always republishes, even when nothing changed: the timestamp is what lets
// the bridge tell a live companion from a state file left behind by an exited
// Vesktop, so skipping an unchanged payload would read as the companion dying.
async function publish() {
    if (publishing) return;
    publishing = true;
    try {
        await applyCommands();
        await Native.publishState(JSON.stringify(snapshot()));
    } finally {
        publishing = false;
    }
}

export default definePlugin({
    name: "End4DiscordVoice",
    description: "Shares Vesktop voice state with the end4-pC Quickshell plugin",
    authors: [{ name: "xephy", id: 0n }],
    enabledByDefault: true,

    flux: {
        VOICE_STATE_UPDATES() { void publish(); },
        AUDIO_TOGGLE_SELF_MUTE() { void publish(); },
        AUDIO_TOGGLE_SELF_DEAF() { void publish(); },
        SPEAKING() { void publish(); },
        STOP_SPEAKING() { void publish(); }
    },

    start() {
        void publish();
        timer = setInterval(() => void publish(), 1000);
    },

    stop() {
        if (timer) clearInterval(timer);
        timer = undefined;
    }
});
