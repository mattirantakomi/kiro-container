# Kiro IDE Docker Container

Docker-kontaineri, jossa ajetaan Kiro IDE:tä VNC-palvelimen kautta. Tämä mahdollistaa IDE:n käytön turvallisesti ilman riskiä oman koneen sotkemisesta.

## Ominaisuudet

- Ubuntu 26.04 LTS (Resolute Raccoon) -pohja
- Kiro IDE esiasennettu
- TigerVNC-palvelin (portti 5901)
- noVNC web-client (portti 6080) — käytettävissä selaimella
- XFCE4-työpöytäympäristö (kevyt)
- Projekti-tiedostot mountataan `./workspace`-hakemistosta

## Käynnistys

```bash
docker compose up --build
```

## Yhdistäminen

### Selaimella (noVNC)

Avaa: http://localhost:6080/vnc.html

### VNC-clientillä

Yhdistä osoitteeseen: `localhost:5901`  
Oletussalasana: `kiro123`

## Kiro IDE:n käynnistys

Kun olet yhdistänyt VNC-työpöytään, avaa terminaali ja aja:

```bash
kiro-ide --no-sandbox
```

## Ympäristömuuttujat

| Muuttuja | Oletus | Kuvaus |
|----------|--------|--------|
| `VNC_PASSWORD` | `kiro123` | VNC-salasana |
| `VNC_RESOLUTION` | `1920x1080` | Työpöydän resoluutio |

## Workspace

Kansio `./workspace` mountataan kontaineriin polkuun `/home/kiro/workspace`. Tallenna projektisi sinne, niin ne säilyvät kontainerin uudelleenkäynnistyksessä.

## Huomioita

- `shm_size: 2gb` on tärkeä Chromium/Electron-pohjaisille sovelluksille (estää kaatumisia)
- `seccomp=unconfined` tarvitaan, jotta Electron-sandbox toimii kontainerissa
- `--no-sandbox` flagi tarvitaan Kiro IDE:n käynnistykseen Docker-kontainerissa
- Kiro vaatii AWS-tilin kirjautumiseen (selainpohjainen OAuth)
