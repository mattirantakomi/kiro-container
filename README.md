# Kiro IDE Docker Container

A Docker container running Kiro IDE with a VNC server and xpra support. This allows you to use the IDE safely without risking your host machine's configuration.

## Features

- Based on Ubuntu 26.04 LTS (Resolute Raccoon)
- Kiro IDE pre-installed and launches automatically
- Google Chrome for OAuth login (opens inside the container)
- TigerVNC server (port 5901, no password)
- noVNC web client (port 6080) — accessible via browser, auto-connects
- **Xpra** (port 14500) — forwards just the Kiro window into your host desktop natively
- XFCE4 desktop with taskbar and desktop shortcuts
- Project files mounted from `./workspace`

## Mitä Kiro on?

Kiro on AWS:n kehittämä agentinen IDE, joka rakentuu VS Code -ytimen päälle. Se on suunniteltu viemään AI-avusteinen koodaus pidemmälle kuin tavallinen copilot: sen sijaan että se vain täydentää koodia, se suunnittelee, toteuttaa ja varmistaa kokonaisuuksia itsenäisesti.

### Keskeiset ominaisuudet

**Autopilot-tila**
Kiro toimii itsenäisesti laajoissakin tehtävissä ilman jatkuvaa ohjausta. Se voi lukea koodipohjaa, tehdä muutoksia useisiin tiedostoihin, ajaa komentoja terminaalissa ja korjata virheitä kierros toisensa jälkeen — käyttäjä seuraa muutoksia ja voi peruuttaa tai katkaista milloin tahansa. Vaihtoehtona on **Supervised-tila**, jossa Kiro pyytää hyväksynnän jokaisen muutoksen kohdalla.

**Spec-vetoinen kehitys**
Spec-sessioissa Kiro muuttaa vapaamuotoisen kuvauksen ensin vaatimuksiksi, sitten arkkitehtuurisuunnitelmaksi ja lopuksi järjestetyksi tehtävälistaksi — jonka se toteuttaa itsenäisesti. Tämä lähestymistapa tuottaa ylläpidettävämpää koodia ja sopii erityisesti monimutkaisiin ominaisuuksiin.

**Agentit ja hookit**
Kiro tukee omia agentteja (`.kiro/agents/`), jotka voidaan käynnistää automaattisesti tapahtumilla (tiedoston tallennus, session aloitus, tehtävän valmistuminen jne.). Tämä mahdollistaa esimerkiksi automaattisen linttauksen tai testauksen ilman manuaalista käynnistystä.

**Steering-tiedostot**
Projektikohtaiset ohjeet, koodausstandardit ja konteksti voidaan kirjoittaa `.kiro/steering/*.md`-tiedostoihin, jotka Kiro lukee automaattisesti jokaisessa sessiossa.

**MCP-tuki**
Model Context Protocol -palvelimia voidaan liittää Kiroon, jolloin agentilla on pääsy ulkoisiin työkaluihin ja dataan (tietokannat, API:t, dokumentaatio jne.).

**Muuta**
- Kuvien ja dokumenttien liittäminen chattiin (UI-mockup → toteutus)
- Realtime-koodimuutosten näyttäminen diff-näkymässä
- Automaattiset commit-viestit suoraan lähdekoodi-paneelista
- Älykkäät virheanalyysit syntaksi-, tyyppi- ja semantiikkavirheille
- Per-prompt -krediittien kulutus näkyy reaaliajassa

### Tuetut kielimallit

Kiro tarjoaa pääsyn Anthropicin, OpenAI:n ja avoimen lähdekoodin malleihin. Mallin voi vaihtaa sessiokohtaisesti:

| Malli | Kuvaus |
|-------|--------|
| **Auto** | Oletusvalinta — reitittää automaattisesti frontier-malleihin (Sonnet + erikoistuneet mallit) latenssin, laadun ja kustannusten tasapainottamiseksi |
| **Claude Opus 4.8** | Luotettava huippumalli vaativaan koodaukseen ja päättelyyn |
| **Claude Sonnet 5** | Nopea ja tasapainoinen, lähestyy Opus-tasoa tehokkaammalla tokeninkäytöllä |
| **Claude Sonnet 4.5** | Saatavilla ilmaiselle tasolle |
| **GPT-5.6 Sol** | OpenAI:n lippulaivamalli, uusin lisäys — huipputulos pitkissä monivaiheisissa tehtävissä (272K konteksti) |
| **GPT-5.6 Terra** | Tasapainoinen vaihtoehto Sol:lle pienemmällä hinnalla |
| **GPT-5.6 Luna** | Kustannustehokkain OpenAI-vaihtoehto, suoriutuu silti Opus 4.8:a paremmin |
| **Qwen3 Coder Next** | Avoin malli, saatavilla kaikille tasoille |
| **DeepSeek 3.2** | Avoin malli, saatavilla kaikilla tasoilla |
| **MiniMax M2.1** | Avoin malli, monikielinen tuki, saatavilla kaikilla tasoilla |

> Mallien saatavuus vaihtelee tilauksen tason ja alueen mukaan. Ilmaistasolla on pääsy Claude Sonnet 4.5:een ja avoimiin malleihin.

## Getting Started

```bash
docker compose up --build
```

## Connecting

### Xpra — native window forwarding (recommended)

Xpra forwards the Kiro IDE window directly into your Ubuntu desktop. The window behaves like any local app: it gets its own taskbar entry, you can resize it, alt-tab to it, etc.

**Install xpra on your Ubuntu host** (once):

> **Tärkeää:** Käytä xpra.org:n virallista repoa, älä Ubuntu:n omaa pakettia. Ubuntu 22.04:n
> vakiopaketti on versio 3.x, mutta container ajaa versiota 6.x — versioero aiheuttaa
> `invalid compression: zlib is not available` -virheen yhdistettäessä.

```bash
# Selvitä Ubuntu-versiotunniste:
# jammy = 22.04, noble = 24.04, oracular = 24.10, resolute = 26.04
DISTRO="jammy"   # <-- muuta tähän oma versiosi

# Poista vanha ubuntu-paketti jos asennettu
sudo apt remove -y xpra 2>/dev/null || true

# Lisää xpra.org:n virallinen repo
sudo apt install -y ca-certificates wget
sudo wget -O /usr/share/keyrings/xpra.asc https://xpra.org/xpra.asc
sudo wget -O /etc/apt/sources.list.d/xpra.sources \
    "https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/${DISTRO}/xpra.sources"
sudo apt update && sudo apt install -y xpra
```

**Connect:**

```bash
xpra attach tcp://localhost:14500
```

The Kiro IDE window appears on your desktop. Close the xpra client to disconnect (the container keeps running).

### noVNC — browser access

```
http://localhost:6080
```

Auto-connects and scales to your browser window. No password needed.

### VNC client

```
localhost:5901  (no password)
```

## Signing In

When Kiro prompts for sign-in, click the link inside the Kiro window. Google Chrome will open inside the container and handle the OAuth flow. Complete the AWS Builder ID login there.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution (VNC/noVNC) |
| `XPRA_PORT` | `14500` | TCP port for the xpra server |

## Workspace

The `./workspace` folder is mounted into the container at `/home/kiro/workspace`. Save your projects there so they persist across container restarts.

## Notes

- All session data (Kiro config, browser profile) is cleaned on every container start for a fresh login
- `shm_size: 2gb` is required for Chromium/Electron apps (prevents crashes)
- `SYS_ADMIN` capability is needed for XFCE's icon rendering (glycin/bubblewrap sandbox)
- Desktop shortcuts for Kiro IDE and Chrome are on the desktop
- Taskbar at the top shows running windows (click to restore minimized apps)
- Xpra runs on display `:2` separately from VNC (`:1`), so both can be used simultaneously
