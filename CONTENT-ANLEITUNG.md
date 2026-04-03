# Inhalte selbst aktualisieren

Du kannst Angebote, Fotos und Videos jetzt ohne HTML-Bearbeitung aktualisieren.

## 1) Inhalte bearbeiten

Datei öffnen:

`content/site-content.json`

Hier kannst du ändern:

- `offersHeadline`, `offersDescription`
- `offers` (Titel, Preis, Texte, Button, Bild)
- `mediaTitle`, `mediaDescription`
- `mediaItems` (Bilder und Videos)

## 2) Eigene Fotos/Videos hochladen

Lege Dateien in:

`assets/uploads/`

Beispiel-Pfade in der JSON:

- Bild: `"image": "assets/uploads/angebot-b196.jpg"`
- Video: `"src": "assets/uploads/fahrschule-video.mp4"`

Für Videos in `mediaItems`:

```json
{
  "type": "video",
  "src": "assets/uploads/fahrschule-video.mp4",
  "poster": "assets/uploads/video-vorschau.jpg",
  "caption": "Unsere Fahrschule im Alltag"
}
```

## 3) Website neu bauen

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Furkan\Documents\New project\build-static-site.ps1"
```

## 4) Lokal prüfen

`index.html` und `angebote/index.html` im Browser öffnen.

## 5) Neu online stellen

Danach die aktualisierten Dateien wieder bei Netlify deployen.
