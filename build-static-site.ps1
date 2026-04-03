$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataPath = Join-Path $projectRoot "website-preview-data.json"
$contentConfigPath = Join-Path $projectRoot "content\site-content.json"
$googleReviewsUrl = "https://www.google.com/search?client=opera&q=www.fahrschule-gaildorf&sourceid=opera&ie=UTF-8&oe=UTF-8#sv=CAwShgIKBmxjbF9wdhI5CgNwdnESMkNnMHZaeTh4TVhaeWREVnRNbXRvSWhRS0RuZDNkeTVtWVdoeWMyTm9kV3hsRUFJWUF3EnsKA2xxaRJ0Q2hkM2QzY3VabUZvY25OamFIVnNaUzFuWVdsc1pHOXlaa2l2bE9hUzM3cUFnQWhhSVJBQUVBRVlBUmdDSWhkM2QzY2dabUZvY25OamFIVnNaU0JuWVdsc1pHOXlacElCRG1SeWFYWnBibWRmYzJOb2IyOXMSEgoDdGJzEgtscmY6ITNzSUFFPRIcCgFxEhd3d3cuZmFocnNjaHVsZS1nYWlsZG9yZhoSbG9jYWwtcGxhY2Utdmlld2VyGAog89HomAk"
$contactEmail = "info@fahrschule-gaildorf.de"
$whatsAppLink = "https://wa.me/491623745772?text=Hallo%20City%20Fahrschule%20Gaildorf%2C%20ich%20habe%20eine%20Frage%20zur%20Anmeldung."
$logoRelativePath = "assets/logo-city-fahrschule-gaildorf.png"

if (-not (Test-Path -LiteralPath $dataPath -PathType Leaf)) {
  throw "Missing file: $dataPath"
}

$data = Get-Content -Raw -Encoding UTF8 -LiteralPath $dataPath | ConvertFrom-Json
$website = $data.data.websitePreview
$homepage = $website.homepage

$defaultContentConfigJson = @'
{
  "offersHeadline": "Aktuelle Angebote",
  "offersDescription": "Bearbeite diese Angebote zentral in content/site-content.json und veröffentliche danach neu.",
  "offers": [
    {
      "badge": "Beliebt",
      "title": "Klasse B Kompaktpaket",
      "description": "Schneller Einstieg mit klarer Struktur für Theorie und Praxis.",
      "price": "ab 899 €",
      "highlights": [
        "Persönliche Betreuung",
        "Flexible Fahrzeiten",
        "Transparente Kosten"
      ],
      "ctaLabel": "Jetzt anfragen",
      "ctaHref": "/anmeldung",
      "image": "https://assets.ls-assets.com/provider/istock/1158973111.jpg?w=1200",
      "imageAlt": "Klasse B Angebot"
    },
    {
      "badge": "Neu",
      "title": "B196 Schnellstart",
      "description": "Ideal für alle, die 125er fahren möchten ohne separate Prüfung.",
      "price": "ab 799 €",
      "highlights": [
        "Strukturierte Schulung",
        "Schneller Start",
        "Moderne Fahrzeuge"
      ],
      "ctaLabel": "B196 anfragen",
      "ctaHref": "/anmeldung",
      "image": "https://assets.ls-assets.com/provider/istock/1752378092.jpg?w=1200",
      "imageAlt": "B196 Angebot"
    }
  ],
  "mediaTitle": "Fotos und Videos",
  "mediaDescription": "Lade eigene Bilder und Videos in assets/uploads hoch und trage die Pfade hier ein.",
  "mediaItems": [
    {
      "type": "image",
      "src": "https://assets.ls-assets.com/provider/istock/2188546569.jpg?w=1200",
      "alt": "Motorrad Ausbildung",
      "caption": "Praxisnahe Ausbildung mit moderner Fahrzeugflotte"
    },
    {
      "type": "image",
      "src": "https://assets.ls-assets.com/provider/istock/2247823320.jpg?w=1200",
      "alt": "Anhänger Ausbildung",
      "caption": "Individuelle Begleitung bis zur Prüfung"
    }
  ]
}
'@

$siteContent = $defaultContentConfigJson | ConvertFrom-Json
if (Test-Path -LiteralPath $contentConfigPath -PathType Leaf) {
  try {
    $siteContent = Get-Content -Raw -Encoding UTF8 -LiteralPath $contentConfigPath | ConvertFrom-Json
  } catch {
    Write-Warning "Die Datei '$contentConfigPath' enthält ungültiges JSON. Es werden Standardinhalte verwendet."
  }
}

function Get-FriendlyTitle {
  param([string]$Slug)

  switch ($Slug) {
    "home" { "Fahrschule City Gaildorf" }
    "anmeldung" { "Anmeldung" }
    "preise" { "Preise" }
    "kontakt" { "Kontakt" }
    "fuehrerscheinklassen" { "Führerscheinklassen" }
    "fuehrerscheinklassen/klasse-b" { "Klasse B" }
    "fuehrerscheinklassen/klasse-be" { "Klasse BE" }
    "fuehrerscheinklassen/klasse-c" { "Klasse C" }
    "fuehrerscheinklassen/klasse-a" { "Klasse A" }
    "fuehrerscheinklassen/b196" { "B196" }
    "standorte" { "Standorte" }
    "angebote" { "Angebote" }
    "ablauf" { "Ablauf" }
    "intensivkurs" { "Intensivkurs" }
    "ueber-uns" { "Über uns" }
    "faq" { "FAQ" }
    "impressum" { "Impressum" }
    "datenschutz" { "Datenschutz" }
    "jobs" { "Jobs" }
    default {
      $last = ($Slug -split "/")[-1]
      if ([string]::IsNullOrWhiteSpace($last)) { return "Seite" }
      return (($last -split "-") | ForEach-Object {
          if ($_.Length -le 1) { $_.ToUpperInvariant() } else { $_.Substring(0,1).ToUpperInvariant() + $_.Substring(1) }
        }) -join " "
    }
  }
}

function Get-PageFilePath {
  param([string]$Slug)

  if ([string]::IsNullOrWhiteSpace($Slug) -or $Slug -eq "home") {
    return Join-Path $projectRoot "index.html"
  }

  $folderPath = Join-Path $projectRoot ($Slug -replace "/", "\")
  if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
  }

  return Join-Path $folderPath "index.html"
}

function Get-RelativeFileHref {
  param(
    [string]$FromSlug,
    [string]$ToSlug
  )

  [string[]]$fromParts = if ([string]::IsNullOrWhiteSpace($FromSlug) -or $FromSlug -eq "home") {
    @()
  } else {
    @($FromSlug -split "/")
  }

  [string[]]$toParts = if ([string]::IsNullOrWhiteSpace($ToSlug) -or $ToSlug -eq "home") {
    @()
  } else {
    @($ToSlug -split "/")
  }

  while ($fromParts.Length -gt 0 -and $toParts.Length -gt 0 -and $fromParts[0] -eq $toParts[0]) {
    if ($fromParts.Length -gt 1) {
      $fromParts = @($fromParts | Select-Object -Skip 1)
    } else {
      $fromParts = @()
    }

    if ($toParts.Length -gt 1) {
      $toParts = @($toParts | Select-Object -Skip 1)
    } else {
      $toParts = @()
    }
  }

  $up = ""
  if ($fromParts.Length -gt 0) {
    $up = [string]::Concat((1..$fromParts.Length | ForEach-Object { "../" }))
  }

  $down = if ($toParts.Length -eq 0) {
    "index.html"
  } else {
    ($toParts -join "/") + "/index.html"
  }

  return "$up$down"
}

function Get-RelativeAssetPath {
  param(
    [string]$FromSlug,
    [string]$AssetRelativePath
  )

  $depth = if ([string]::IsNullOrWhiteSpace($FromSlug) -or $FromSlug -eq "home") {
    0
  } else {
    ($FromSlug -split "/").Count
  }

  if ($depth -le 0) {
    return $AssetRelativePath
  }

  $prefix = [string]::Concat((1..$depth | ForEach-Object { "../" }))
  return "$prefix$AssetRelativePath"
}

function Convert-InternalHref {
  param(
    [string]$Href,
    [string]$CurrentSlug
  )

  if ([string]::IsNullOrWhiteSpace($Href)) {
    return $Href
  }

  if ($Href -eq "#") {
    return Get-RelativeFileHref -FromSlug $CurrentSlug -ToSlug "kontakt"
  }

  if ($Href.StartsWith("http://") -or $Href.StartsWith("https://") -or $Href.StartsWith("mailto:") -or $Href.StartsWith("tel:") -or $Href.StartsWith("#")) {
    return $Href
  }

  if (-not $Href.StartsWith("/")) {
    return $Href
  }

  $pathPart = $Href
  $suffix = ""
  $queryIndex = $Href.IndexOf("?")
  $anchorIndex = $Href.IndexOf("#")
  $cutIndex = -1

  if ($queryIndex -ge 0 -and $anchorIndex -ge 0) {
    $cutIndex = [Math]::Min($queryIndex, $anchorIndex)
  } elseif ($queryIndex -ge 0) {
    $cutIndex = $queryIndex
  } elseif ($anchorIndex -ge 0) {
    $cutIndex = $anchorIndex
  }

  if ($cutIndex -ge 0) {
    $pathPart = $Href.Substring(0, $cutIndex)
    $suffix = $Href.Substring($cutIndex)
  }

  $targetSlug = $pathPart.Trim("/")
  if ([string]::IsNullOrWhiteSpace($targetSlug)) {
    $targetSlug = "home"
  }

  $relativeHref = Get-RelativeFileHref -FromSlug $CurrentSlug -ToSlug $targetSlug
  return "$relativeHref$suffix"
}

function Rewrite-Hrefs {
  param(
    [string]$Html,
    [string]$CurrentSlug
  )

  return [regex]::Replace($Html, 'href="([^"]*)"', {
      param($match)
      $original = $match.Groups[1].Value
      $updated = Convert-InternalHref -Href $original -CurrentSlug $CurrentSlug
      return 'href="' + $updated + '"'
    })
}

function Get-TextValue {
  param(
    [AllowNull()][object]$Value,
    [string]$Default = ""
  )

  if ($null -eq $Value) {
    return $Default
  }

  $text = [string]$Value
  if ([string]::IsNullOrWhiteSpace($text)) {
    return $Default
  }

  return $text.Trim()
}

function Escape-Html {
  param([AllowNull()][object]$Value)
  return [System.Net.WebUtility]::HtmlEncode((Get-TextValue -Value $Value))
}

function Convert-AssetPath {
  param(
    [string]$Path,
    [string]$CurrentSlug
  )

  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $Path
  }

  if (
    $Path.StartsWith("http://") -or
    $Path.StartsWith("https://") -or
    $Path.StartsWith("data:") -or
    $Path.StartsWith("blob:") -or
    $Path.StartsWith("file://") -or
    $Path.StartsWith("./") -or
    $Path.StartsWith("../")
  ) {
    return $Path
  }

  $assetRelative = if ($Path.StartsWith("/")) { $Path.TrimStart("/") } else { $Path }
  return Get-RelativeAssetPath -FromSlug $CurrentSlug -AssetRelativePath $assetRelative
}

function Rewrite-AssetAttributes {
  param(
    [string]$Html,
    [string]$CurrentSlug
  )

  return [regex]::Replace($Html, '(src|poster)="([^"]*)"', {
      param($match)
      $attribute = $match.Groups[1].Value
      $originalValue = $match.Groups[2].Value
      $updatedValue = Convert-AssetPath -Path $originalValue -CurrentSlug $CurrentSlug
      return $attribute + '="' + $updatedValue + '"'
    })
}

$sectionsById = @{}
foreach ($section in $homepage.codeSections) {
  $sectionsById[$section.id] = [string]$section.html
}

function Build-FallbackSection {
  param(
    [string]$Slug,
    [string]$Title
  )

  $description = "Diese Seite wird aktuell vorbereitet. Bitte melde dich telefonisch für schnelle Unterstützung."

  if ($Slug -eq "jobs") {
    $description = "Momentan sind keine offenen Stellen veröffentlicht. Initiativanfragen sind willkommen."
  } elseif ($Slug -eq "datenschutz") {
    $description = "Diese Datenschutz-Seite ist ein Platzhalter und sollte vor dem Livegang rechtlich finalisiert werden."
  } elseif ($Slug -eq "faq") {
    $description = "FAQ-Inhalte folgen. Bis dahin helfen wir dir gerne direkt am Telefon."
  }

  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-10 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-flex items-center bg-[#1D3557] text-white px-4 py-2 rounded-full text-sm font-semibold mb-6">
        Seite in Bearbeitung
      </span>
      <h1 class="text-3xl md:text-4xl font-bold text-[#1D1D1F] mb-4" style="font-family: var(--font-family-heading);">$Title</h1>
      <p class="text-lg text-[#6C757D] mb-8">$description</p>
      <div class="flex flex-col sm:flex-row gap-4">
        <a href="/kontakt" class="bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300 text-center">
          Kontakt aufnehmen
        </a>
        <a href="tel:01623745772" class="bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300 text-center">
          0162 3745772 anrufen
        </a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-RegistrationSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">Jetzt anmelden</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-4" style="font-family: var(--font-family-heading);">
        Anmeldung
      </h1>
      <p class="text-lg text-[#6C757D] max-w-3xl mx-auto">
        Trage deine Daten direkt ein. Wir melden uns schnellstmöglich bei dir zurück.
      </p>
    </div>

    <div class="bg-white rounded-3xl shadow-xl border border-[#E8E8EA] p-8 lg:p-10">
      <form id="anmeldung-form" class="grid grid-cols-1 md:grid-cols-2 gap-6" novalidate>
        <div class="md:col-span-2">
          <label for="anmeldung-name" class="block text-sm font-semibold text-[#1D3557] mb-2">Name</label>
          <input id="anmeldung-name" name="name" type="text" required class="w-full rounded-xl border border-[#E8E8EA] px-4 py-3 outline-none focus:ring-2 focus:ring-[#1E3A5F]" placeholder="Vor- und Nachname">
        </div>

        <div class="md:col-span-2">
          <label for="anmeldung-anschrift" class="block text-sm font-semibold text-[#1D3557] mb-2">Anschrift</label>
          <input id="anmeldung-anschrift" name="anschrift" type="text" required class="w-full rounded-xl border border-[#E8E8EA] px-4 py-3 outline-none focus:ring-2 focus:ring-[#1E3A5F]" placeholder="Straße, Hausnummer, PLZ, Ort">
        </div>

        <div>
          <label for="anmeldung-telefon" class="block text-sm font-semibold text-[#1D3557] mb-2">Telefonnummer</label>
          <input id="anmeldung-telefon" name="telefon" type="tel" required class="w-full rounded-xl border border-[#E8E8EA] px-4 py-3 outline-none focus:ring-2 focus:ring-[#1E3A5F]" placeholder="+49 ...">
        </div>

        <div>
          <label for="anmeldung-email" class="block text-sm font-semibold text-[#1D3557] mb-2">E-Mail</label>
          <input id="anmeldung-email" name="email" type="email" required class="w-full rounded-xl border border-[#E8E8EA] px-4 py-3 outline-none focus:ring-2 focus:ring-[#1E3A5F]" placeholder="name@beispiel.de">
        </div>

        <div class="md:col-span-2">
          <label for="anmeldung-klasse" class="block text-sm font-semibold text-[#1D3557] mb-2">Führerscheinklasse</label>
          <select id="anmeldung-klasse" name="fuehrerscheinklasse" required class="w-full rounded-xl border border-[#E8E8EA] px-4 py-3 outline-none focus:ring-2 focus:ring-[#1E3A5F] bg-white">
            <option value="" selected disabled>Bitte auswählen</option>
            <option value="Klasse B">Klasse B</option>
            <option value="Klasse BE">Klasse BE</option>
            <option value="Klasse C">Klasse C</option>
            <option value="Klasse A">Klasse A</option>
            <option value="B196">B196</option>
            <option value="Sonstiges">Sonstiges</option>
          </select>
          <p class="mt-2 text-sm text-[#6C757D]">Wähle die gewünschte Klasse aus. Details können optional im Nachrichtenfeld ergänzt werden.</p>
        </div>

        <div class="md:col-span-2">
          <label for="anmeldung-nachricht" class="block text-sm font-semibold text-[#1D3557] mb-2">Nachricht (Optional)</label>
          <textarea id="anmeldung-nachricht" name="nachricht" rows="4" class="w-full rounded-xl border border-[#E8E8EA] px-4 py-3 outline-none focus:ring-2 focus:ring-[#1E3A5F]" placeholder="Deine Nachricht"></textarea>
        </div>

        <div class="md:col-span-2 flex flex-col sm:flex-row sm:items-center gap-4">
          <button type="submit" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">
            Anmeldung absenden
          </button>
          <a href="tel:01623745772" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">
            0162 3745772 anrufen
          </a>
        </div>

        <p id="anmeldung-feedback" class="md:col-span-2 hidden text-[#1E3A5F] font-semibold"></p>
      </form>
    </div>
  </div>
</section>
"@
}

function Build-GoogleReviewsSection {
  return @"
<section class="code-section bg-white py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <span class="inline-block bg-[#E63946] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">Google Bewertungen</span>
      <h2 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-4" style="font-family: var(--font-family-heading);">
        Das sagen Fahrschüler über uns
      </h2>
      <p class="text-lg text-[#6C757D] max-w-3xl mx-auto">
        Unser Profil zeigt eine starke Bewertung von 4,9 Sternen. Die aktuellen Bewertungen kannst du direkt bei Google einsehen.
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
      <div class="bg-[#F5F7FA] rounded-2xl p-6 border border-[#E8E8EA] text-center">
        <p class="text-5xl font-bold text-[#1D3557] mb-2">4,9</p>
        <p class="text-[#6C757D] font-medium">Sterne</p>
      </div>
      <div class="bg-[#F5F7FA] rounded-2xl p-6 border border-[#E8E8EA] text-center">
        <p class="text-5xl font-bold text-[#E63946] mb-2">Google</p>
        <p class="text-[#6C757D] font-medium">Unternehmensprofil</p>
      </div>
      <div class="bg-[#F5F7FA] rounded-2xl p-6 border border-[#E8E8EA] text-center">
        <p class="text-5xl font-bold text-[#06A77D] mb-2">Live</p>
        <p class="text-[#6C757D] font-medium">Aktuelle Rezensionen</p>
      </div>
    </div>

    <div class="text-center">
      <a href="$googleReviewsUrl" target="_blank" rel="noopener noreferrer" class="inline-flex items-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">
        Google Bewertungen öffnen
        <i class="fa-solid fa-arrow-right ml-3" aria-hidden="true"></i>
      </a>
      <p class="mt-4 text-sm text-[#6C757D]">
        Hinweis: Google lädt Inhalte dynamisch. Bitte öffne den Link für die vollständige Live-Ansicht aller Rezensionen.
      </p>
    </div>
  </div>
</section>
"@
}

function Build-OffersSectionFromContent {
  $headline = Escape-Html (Get-TextValue -Value $siteContent.offersHeadline -Default "Aktuelle Angebote")
  $description = Escape-Html (Get-TextValue -Value $siteContent.offersDescription -Default "Unsere aktuellen Angebote.")
  $offers = @()

  if ($siteContent -and $siteContent.offers) {
    $offers = @($siteContent.offers)
  }

  $cards = @()
  foreach ($offer in $offers) {
    if ($null -eq $offer) { continue }

    $title = Escape-Html (Get-TextValue -Value $offer.title -Default "Angebot")
    $offerDescription = Escape-Html (Get-TextValue -Value $offer.description -Default "")
    $price = Escape-Html (Get-TextValue -Value $offer.price -Default "Preis auf Anfrage")
    $badge = Escape-Html (Get-TextValue -Value $offer.badge)
    $ctaLabel = Escape-Html (Get-TextValue -Value $offer.ctaLabel -Default "Jetzt anfragen")
    $ctaHref = Escape-Html (Get-TextValue -Value $offer.ctaHref -Default "/anmeldung")
    $image = Escape-Html (Get-TextValue -Value $offer.image -Default "https://assets.ls-assets.com/provider/istock/1158973111.jpg?w=1200")
    $imageAlt = Escape-Html (Get-TextValue -Value $offer.imageAlt -Default $title)

    $highlights = @()
    if ($offer.highlights) {
      foreach ($highlight in @($offer.highlights)) {
        $clean = Get-TextValue -Value $highlight
        if (-not [string]::IsNullOrWhiteSpace($clean)) {
          $highlights += "<li class=`"flex items-start text-sm text-[#1D1D1F]`"><i class=`"fa-solid fa-check text-[#06A77D] mt-1 mr-3`" aria-hidden=`"true`"></i><span>" + (Escape-Html $clean) + "</span></li>"
        }
      }
    }
    if ($highlights.Count -eq 0) {
      $highlights += "<li class=`"flex items-start text-sm text-[#1D1D1F]`"><i class=`"fa-solid fa-check text-[#06A77D] mt-1 mr-3`" aria-hidden=`"true`"></i><span>Individuelle Beratung inklusive</span></li>"
    }

    $badgeHtml = ""
    if (-not [string]::IsNullOrWhiteSpace($badge)) {
      $badgeHtml = "<span class=`"absolute top-4 left-4 bg-[#E63946] text-white px-3 py-1 rounded-full text-xs font-bold`">$badge</span>"
    }

    $cards += @"
      <article class="bg-white rounded-2xl shadow-lg border border-[#E8E8EA] overflow-hidden flex flex-col">
        <div class="relative h-52 overflow-hidden">
          <img src="$image" alt="$imageAlt" class="w-full h-full object-cover">
          $badgeHtml
        </div>
        <div class="p-6 flex flex-col h-full">
          <h3 class="text-2xl font-bold text-[#1D3557] mb-2">$title</h3>
          <p class="text-[#6C757D] mb-4">$offerDescription</p>
          <p class="text-3xl font-bold text-[#E63946] mb-5">$price</p>
          <ul class="space-y-2 mb-6">
            $($highlights -join "`n            ")
          </ul>
          <a href="$ctaHref" class="mt-auto inline-flex items-center justify-center bg-[#1E3A5F] text-white px-6 py-3 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">
            $ctaLabel
          </a>
        </div>
      </article>
"@
  }

  if ($cards.Count -eq 0) {
    $cards += @"
      <article class="bg-white rounded-2xl shadow-lg border border-[#E8E8EA] p-8">
        <h3 class="text-2xl font-bold text-[#1D3557] mb-3">Angebote folgen</h3>
        <p class="text-[#6C757D] mb-6">Lege Angebote in <code>content/site-content.json</code> an und generiere die Website neu.</p>
        <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-6 py-3 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">
          Jetzt anmelden
        </a>
      </article>
"@
  }

  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">Angebote</span>
      <h2 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-4" style="font-family: var(--font-family-heading);">$headline</h2>
      <p class="text-lg text-[#6C757D] max-w-3xl mx-auto">$description</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
      $($cards -join "`n")
    </div>
  </div>
</section>
"@
}

function Build-MediaShowcaseSectionFromContent {
  $title = Escape-Html (Get-TextValue -Value $siteContent.mediaTitle -Default "Fotos und Videos")
  $description = Escape-Html (Get-TextValue -Value $siteContent.mediaDescription -Default "Eindrücke aus unserer Fahrschule.")
  $mediaItems = @()
  if ($siteContent -and $siteContent.mediaItems) {
    $mediaItems = @($siteContent.mediaItems)
  }

  $cards = @()
  foreach ($item in $mediaItems) {
    if ($null -eq $item) { continue }

    $type = (Get-TextValue -Value $item.type -Default "image").ToLowerInvariant()
    $src = Escape-Html (Get-TextValue -Value $item.src)
    if ([string]::IsNullOrWhiteSpace($src)) { continue }

    $alt = Escape-Html (Get-TextValue -Value $item.alt -Default "Medieninhalt")
    $caption = Escape-Html (Get-TextValue -Value $item.caption)
    $captionHtml = if ([string]::IsNullOrWhiteSpace($caption)) { "" } else { "<p class=`"mt-3 text-sm text-[#6C757D]`">$caption</p>" }

    if ($type -eq "video") {
      $poster = Escape-Html (Get-TextValue -Value $item.poster)
      $posterAttribute = if ([string]::IsNullOrWhiteSpace($poster)) { "" } else { " poster=`"$poster`"" }
      $cards += @"
      <article class="bg-white rounded-2xl shadow-lg border border-[#E8E8EA] overflow-hidden">
        <video controls preload="metadata" playsinline class="w-full h-64 object-cover bg-black"$posterAttribute>
          <source src="$src" type="video/mp4">
          Dein Browser unterstützt kein HTML5-Video.
        </video>
        <div class="p-4">
          $captionHtml
        </div>
      </article>
"@
    } else {
      $cards += @"
      <article class="bg-white rounded-2xl shadow-lg border border-[#E8E8EA] overflow-hidden">
        <img src="$src" alt="$alt" class="w-full h-64 object-cover">
        <div class="p-4">
          $captionHtml
        </div>
      </article>
"@
    }
  }

  if ($cards.Count -eq 0) {
    $cards += @"
      <article class="bg-white rounded-2xl shadow-lg border border-[#E8E8EA] p-8">
        <h3 class="text-2xl font-bold text-[#1D3557] mb-3">Noch keine Medien hinterlegt</h3>
        <p class="text-[#6C757D]">Trage Bilder und Videos in <code>content/site-content.json</code> ein, um sie hier zu zeigen.</p>
      </article>
"@
  }

  return @"
<section class="code-section bg-white py-20 lg:py-28">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">Medien</span>
      <h2 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-4" style="font-family: var(--font-family-heading);">$title</h2>
      <p class="text-lg text-[#6C757D] max-w-3xl mx-auto">$description</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
      $($cards -join "`n")
    </div>
  </div>
</section>
"@
}

function Build-LicenseQuickLinksSection {
  return @"
<section class="code-section bg-white py-16 lg:py-20">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-10">
      <h2 class="text-3xl md:text-4xl font-bold text-[#1D1D1F] mb-3" style="font-family: var(--font-family-heading);">Weitere Führerscheinklassen</h2>
      <p class="text-lg text-[#6C757D] max-w-3xl mx-auto">Du kannst jederzeit zwischen den Klassen wechseln und dir die passende Ausbildung ansehen.</p>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
      <a href="/fuehrerscheinklassen/klasse-b" class="inline-flex items-center justify-center rounded-xl border border-[#E8E8EA] bg-[#F5F7FA] px-5 py-4 font-semibold text-[#1D3557] hover:bg-[#1D3557] hover:text-white transition-all duration-300">Klasse B</a>
      <a href="/fuehrerscheinklassen/klasse-be" class="inline-flex items-center justify-center rounded-xl border border-[#E8E8EA] bg-[#F5F7FA] px-5 py-4 font-semibold text-[#1D3557] hover:bg-[#1D3557] hover:text-white transition-all duration-300">Klasse BE</a>
      <a href="/fuehrerscheinklassen/klasse-c" class="inline-flex items-center justify-center rounded-xl border border-[#E8E8EA] bg-[#F5F7FA] px-5 py-4 font-semibold text-[#1D3557] hover:bg-[#1D3557] hover:text-white transition-all duration-300">Klasse C</a>
      <a href="/fuehrerscheinklassen/klasse-a" class="inline-flex items-center justify-center rounded-xl border border-[#E8E8EA] bg-[#F5F7FA] px-5 py-4 font-semibold text-[#1D3557] hover:bg-[#1D3557] hover:text-white transition-all duration-300">Klasse A</a>
      <a href="/fuehrerscheinklassen/b196" class="inline-flex items-center justify-center rounded-xl border border-[#E8E8EA] bg-[#F5F7FA] px-5 py-4 font-semibold text-[#1D3557] hover:bg-[#1D3557] hover:text-white transition-all duration-300">B196</a>
    </div>
  </div>
</section>
"@
}

function Build-KlasseBInfoSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-8 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-5">Klasse B</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-5" style="font-family: var(--font-family-heading);">Auto-Führerschein Klasse B</h1>
      <p class="text-lg text-[#6C757D] mb-8 max-w-4xl">Mit der Klasse B darfst du Pkw bis 3.500 kg zulässiger Gesamtmasse fahren. Ideal für Alltag, Ausbildung und Beruf.</p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-8">
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Mindestalter:</strong> <span class="text-[#1D1D1F]">In der Regel 18 Jahre, begleitetes Fahren ab 17 möglich.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Ausbildung:</strong> <span class="text-[#1D1D1F]">Theorieunterricht, Fahrstunden und praktische Prüfung.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Fahrzeug:</strong> <span class="text-[#1D1D1F]">Pkw mit bis zu 8 Sitzplätzen (zusätzlich zum Fahrersitz).</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Hinweis:</strong> <span class="text-[#1D1D1F]">Alle Details zur Anhängerregelung klären wir transparent im Beratungsgespräch.</span></div>
      </div>

      <div class="flex flex-col sm:flex-row gap-4">
        <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">Jetzt für Klasse B anmelden</a>
        <a href="/preise" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">Preise ansehen</a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-KlasseBEInfoSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-8 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-5">Klasse BE</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-5" style="font-family: var(--font-family-heading);">Anhänger-Führerschein Klasse BE</h1>
      <p class="text-lg text-[#6C757D] mb-8 max-w-4xl">Mit der Klasse BE fährst du Kombinationen aus Zugfahrzeug der Klasse B und schwerem Anhänger. Perfekt für Beruf, Hobby und Transport.</p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-8">
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Voraussetzung:</strong> <span class="text-[#1D1D1F]">Du benötigst die Fahrerlaubnis Klasse B.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Anhänger:</strong> <span class="text-[#1D1D1F]">Anhänger mit bis zu 3.500 kg zulässiger Gesamtmasse.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Ausbildung:</strong> <span class="text-[#1D1D1F]">Praxisorientierte Fahrstunden mit Fokus auf Rangieren und Sicherheit.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Prüfung:</strong> <span class="text-[#1D1D1F]">Praktische Prüfung mit realistischen Fahraufgaben.</span></div>
      </div>

      <div class="flex flex-col sm:flex-row gap-4">
        <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">Jetzt für Klasse BE anmelden</a>
        <a href="/kontakt" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">Beratung anfragen</a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-KlasseAInfoSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-8 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-5">Klasse A</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-5" style="font-family: var(--font-family-heading);">Motorrad-Führerschein Klasse A</h1>
      <p class="text-lg text-[#6C757D] mb-8 max-w-4xl">Mit der Klasse A darfst du Krafträder ohne Leistungsbeschränkung fahren. Ideal für alle, die auf zwei Rädern flexibel und sicher unterwegs sein möchten.</p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-8">
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Mindestalter:</strong> <span class="text-[#1D1D1F]">In der Regel 24 Jahre beim Direkteinstieg.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Stufenaufstieg:</strong> <span class="text-[#1D1D1F]">Früher möglich bei Vorbesitz anderer Motorradklassen.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Ausbildung:</strong> <span class="text-[#1D1D1F]">Theorie, Grundfahraufgaben und Praxisfahrten mit Prüfungsvorbereitung.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Vorteil:</strong> <span class="text-[#1D1D1F]">Uneingeschränkte Motorradklasse für maximale Freiheit.</span></div>
      </div>

      <div class="flex flex-col sm:flex-row gap-4">
        <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">Jetzt für Klasse A anmelden</a>
        <a href="/kontakt" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">Beratung anfragen</a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-KlasseCInfoSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-8 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-5">Klasse C</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-5" style="font-family: var(--font-family-heading);">Lkw-Führerschein Klasse C</h1>
      <p class="text-lg text-[#6C757D] mb-8 max-w-4xl">Die Klasse C ist ideal für den professionellen Güterverkehr. Damit darfst du Lkw über 3.500 kg zulässiger Gesamtmasse fahren.</p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-8">
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Voraussetzung:</strong> <span class="text-[#1D1D1F]">Vorhandene Fahrerlaubnis Klasse B.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Mindestalter:</strong> <span class="text-[#1D1D1F]">Regelmäßig 21 Jahre, in bestimmten Ausbildungen früher möglich.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Anhänger:</strong> <span class="text-[#1D1D1F]">Anhänger bis 750 kg zulässiger Gesamtmasse.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Beruflicher Nutzen:</strong> <span class="text-[#1D1D1F]">Starke Grundlage für Logistik, Transport und Lieferverkehr.</span></div>
      </div>

      <div class="flex flex-col sm:flex-row gap-4">
        <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">Jetzt für Klasse C anmelden</a>
        <a href="/kontakt" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">Beratung anfragen</a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-B196InfoSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-8 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-5">B196</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-5" style="font-family: var(--font-family-heading);">B196 Erweiterung</h1>
      <p class="text-lg text-[#6C757D] mb-8 max-w-4xl">Mit der B196-Erweiterung darfst du 125er-Motorräder fahren, ohne eine zusätzliche praktische Prüfung abzulegen. Ideal für den schnellen Einstieg auf zwei Rädern.</p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-8">
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Voraussetzung:</strong> <span class="text-[#1D1D1F]">Du besitzt die Fahrerlaubnis Klasse B.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Mindestalter:</strong> <span class="text-[#1D1D1F]">Mindestens 25 Jahre.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Vorbesitz:</strong> <span class="text-[#1D1D1F]">Klasse B seit mindestens 5 Jahren.</span></div>
        <div class="rounded-2xl border border-[#E8E8EA] bg-[#F5F7FA] p-5"><strong class="text-[#1D3557]">Training:</strong> <span class="text-[#1D1D1F]">Theorie und Praxis gemäß gesetzlicher Vorgaben in der Fahrschule.</span></div>
      </div>

      <div class="flex flex-col sm:flex-row gap-4">
        <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">Jetzt für B196 anmelden</a>
        <a href="/kontakt" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">Beratung anfragen</a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-WhatsAppContactSection {
  return @"
<section class="code-section bg-white py-16 lg:py-20">
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="rounded-3xl border border-[#E8E8EA] bg-[#F5F7FA] p-8 lg:p-10 shadow-lg">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
        <div>
          <span class="inline-block bg-[#25D366] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">WhatsApp Kontakt</span>
          <h2 class="text-2xl md:text-3xl font-bold text-[#1D1D1F] mb-3" style="font-family: var(--font-family-heading);">Schreibe uns direkt per WhatsApp</h2>
          <p class="text-[#6C757D] text-lg">Schnelle Rückmeldung zu Anmeldung, Preisen und Führerscheinklassen.</p>
        </div>
        <div class="flex-shrink-0">
          <a href="$whatsAppLink" target="_blank" rel="noopener noreferrer" class="inline-flex items-center justify-center bg-[#25D366] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#1EBE5A] transition-all duration-300">
            <i class="fa-brands fa-whatsapp mr-3" aria-hidden="true"></i>
            WhatsApp öffnen
          </a>
        </div>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-FaqSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <span class="inline-block bg-[#1D3557] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">FAQ</span>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#1D1D1F] mb-4" style="font-family: var(--font-family-heading);">
        Häufig gestellte Fragen
      </h1>
      <p class="text-lg text-[#6C757D] max-w-3xl mx-auto">
        Hier findest du die wichtigsten Antworten rund um Führerscheinklassen, Anmeldung und Ablauf.
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Wie melde ich mich an?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Du kannst dich ganz einfach über unser Online-Formular anmelden. Wähle deine Führerscheinklasse aus und wir melden uns schnellstmöglich bei dir zurück.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Welche Führerscheinklassen bietet ihr an?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Wir bieten unter anderem Klasse B, Klasse BE, Klasse A, Klasse C und B196 an. Auf der Seite Führerscheinklassen findest du zu jeder Klasse eine kurze Übersicht.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Wie viel kostet der Führerschein?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Die Kosten richten sich nach Klasse und individuellem Ausbildungsverlauf. Eine transparente Übersicht findest du auf der Preisseite oder direkt im persönlichen Beratungsgespräch.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Wie lange dauert die Ausbildung?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Die Dauer hängt von deiner Verfügbarkeit und der gewählten Klasse ab. Gemeinsam planen wir die Ausbildung so, dass du zügig und gut vorbereitet zur Prüfung kommst.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Kann ich einen Intensivkurs machen?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Ja, Intensivkurse sind möglich. Kontaktiere uns am besten direkt, damit wir freie Termine und den passenden Ablauf mit dir abstimmen können.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Welche Unterlagen brauche ich?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Für die Anmeldung benötigst du in der Regel einen Ausweis und weitere Unterlagen je nach Klasse. Die genaue Liste erhältst du von uns direkt beim Start.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Wie erreiche ich euch am schnellsten?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Am schnellsten erreichst du uns telefonisch oder per WhatsApp. Alternativ kannst du uns jederzeit eine E-Mail senden.</p>
      </div>

      <div class="bg-white rounded-2xl border border-[#E8E8EA] p-6 shadow-sm">
        <h2 class="text-xl font-bold text-[#1D3557] mb-3">Wann kann ich starten?</h2>
        <p class="text-[#1D1D1F] leading-relaxed">Ein Start ist oft kurzfristig möglich. Melde dich einfach, dann prüfen wir den nächsten freien Einstiegstermin für dich.</p>
      </div>
    </div>

    <div class="mt-10 flex flex-col sm:flex-row gap-4 justify-center">
      <a href="/anmeldung" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">
        Jetzt anmelden
      </a>
      <a href="$whatsAppLink" target="_blank" rel="noopener noreferrer" class="inline-flex items-center justify-center bg-[#25D366] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#1EBE5A] transition-all duration-300">
        <i class="fa-brands fa-whatsapp mr-3" aria-hidden="true"></i>
        WhatsApp schreiben
      </a>
    </div>
  </div>
</section>
"@
}

function Build-JobsSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl p-10 lg:p-12 shadow-xl border border-[#E8E8EA]">
      <span class="inline-block bg-[#E63946] text-white px-4 py-1 rounded-full text-sm font-semibold mb-4">Jobs</span>
      <h1 class="text-3xl md:text-4xl font-bold text-[#1D1D1F] mb-6" style="font-family: var(--font-family-heading);">Fahrlehrer*in</h1>
      <p class="text-lg text-[#1D1D1F] mb-3"><strong>Klasse:</strong> BE und/oder A</p>
      <p class="text-lg text-[#1D1D1F] mb-3">Wir bezahlen übertariflich! Du kommst nicht aus der Umgebung? Für deine Unterkunft ist gesorgt.</p>
      <p class="text-lg text-[#1D1D1F] mb-8">Schicke deine Bewerbung mit Lebenslauf per Mail an $contactEmail</p>
      <div class="flex flex-col sm:flex-row gap-4">
        <a href="mailto:${contactEmail}?subject=Bewerbung%20Fahrlehrer*in" class="inline-flex items-center justify-center bg-[#1E3A5F] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#152A45] transition-all duration-300">
          Bewerbung per E-Mail senden
        </a>
        <a href="tel:01623745772" class="inline-flex items-center justify-center bg-[#D4AF37] text-white px-8 py-4 rounded-xl font-bold hover:bg-[#C19B2C] transition-all duration-300">
          0162 3745772 anrufen
        </a>
      </div>
    </div>
  </div>
</section>
"@
}

function Build-ImpressumSection {
  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl shadow-xl border border-[#E8E8EA] p-8 lg:p-12">
      <h1 class="text-3xl md:text-4xl font-bold text-[#1D1D1F] mb-8" style="font-family: var(--font-family-heading);">Impressum</h1>

      <p class="text-[#1D1D1F] font-semibold mb-6">Angaben gemäß § 5 TMG</p>

      <p class="text-[#1D1D1F] mb-6">
        City Fahrschule Gaildorf GmbH<br>
        Karlstr. 6<br>
        74405 Gaildorf
      </p>

      <h2 class="text-xl font-bold text-[#1D3557] mb-3">Vertreten durch:</h2>
      <p class="text-[#1D1D1F] mb-6">Herrn Salih Kolubüyük</p>

      <h2 class="text-xl font-bold text-[#1D3557] mb-3">Kontakt:</h2>
      <p class="text-[#1D1D1F] mb-6">
        Telefon: + 49 (0) 162 3745772<br>
        E-Mail: $contactEmail
      </p>

      <h2 class="text-xl font-bold text-[#1D3557] mb-3">Registereintrag:</h2>
      <p class="text-[#1D1D1F] mb-6">
        Eintragung im Registergericht: Amtsgericht Stuttgart<br>
        Registernummer: HRB 792215
      </p>

      <h2 class="text-xl font-bold text-[#1D3557] mb-3">Umsatzsteuer-ID:</h2>
      <p class="text-[#1D1D1F] mb-6">
        Umsatzsteuer-Identifikationsnummer gemäß §27a Umsatzsteuergesetz: DE365129565
      </p>

      <h2 class="text-xl font-bold text-[#1D3557] mb-3">Aufsichtsbehörde:</h2>
      <p class="text-[#1D1D1F] mb-8">folgt</p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-4">Haftungsausschluss:</h2>

      <h3 class="text-xl font-bold text-[#1D3557] mb-3">Haftung für Inhalte</h3>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Die Inhalte unserer Seiten wurden mit größter Sorgfalt erstellt. Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte können wir jedoch keine Gewähr übernehmen. Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als Diensteanbieter jedoch nicht verpflichtet, übermittelte oder gespeicherte fremde Informationen zu überwachen oder nach Umständen zu forschen, die auf eine rechtswidrige Tätigkeit hinweisen. Verpflichtungen zur Entfernung oder Sperrung der Nutzung von Informationen nach den allgemeinen Gesetzen bleiben hiervon unberührt. Eine diesbezügliche Haftung ist jedoch erst ab dem Zeitpunkt der Kenntnis einer konkreten Rechtsverletzung möglich. Bei Bekanntwerden von entsprechenden Rechtsverletzungen werden wir diese Inhalte umgehend entfernen.
      </p>

      <h3 class="text-xl font-bold text-[#1D3557] mb-3">Haftung für Links</h3>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Unser Angebot enthält Links zu externen Webseiten Dritter, auf deren Inhalte wir keinen Einfluss haben. Deshalb können wir für diese fremden Inhalte auch keine Gewähr übernehmen. Für die Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter oder Betreiber der Seiten verantwortlich. Die verlinkten Seiten wurden zum Zeitpunkt der Verlinkung auf mögliche Rechtsverstöße überprüft. Rechtswidrige Inhalte waren zum Zeitpunkt der Verlinkung nicht erkennbar. Eine permanente inhaltliche Kontrolle der verlinkten Seiten ist jedoch ohne konkrete Anhaltspunkte einer Rechtsverletzung nicht zumutbar. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Links umgehend entfernen.
      </p>

      <h3 class="text-xl font-bold text-[#1D3557] mb-3">Urheberrecht</h3>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen Seiten unterliegen dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung und jede Art der Verwertung außerhalb der Grenzen des Urheberrechtes bedürfen der schriftlichen Zustimmung des jeweiligen Autors bzw. Erstellers. Downloads und Kopien dieser Seite sind nur für den privaten, nicht kommerziellen Gebrauch gestattet. Soweit die Inhalte auf dieser Seite nicht vom Betreiber erstellt wurden, werden die Urheberrechte Dritter beachtet. Insbesondere werden Inhalte Dritter als solche gekennzeichnet. Sollten Sie trotzdem auf eine Urheberrechtsverletzung aufmerksam werden, bitten wir um einen entsprechenden Hinweis. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Inhalte umgehend entfernen.
      </p>

      <h3 class="text-xl font-bold text-[#1D3557] mb-3">Datenschutz</h3>
      <p class="text-[#1D1D1F] leading-relaxed">
        Die Nutzung unserer Webseite ist in der Regel ohne Angabe personenbezogener Daten möglich. Soweit auf unseren Seiten personenbezogene Daten (beispielsweise Name, Anschrift oder E-Mail-Adressen) erhoben werden, erfolgt dies, soweit möglich, stets auf freiwilliger Basis. Diese Daten werden ohne Ihre ausdrückliche Zustimmung nicht an Dritte weitergegeben.<br>
        Wir weisen darauf hin, dass die Datenübertragung im Internet (z.B. bei der Kommunikation per E-Mail) Sicherheitslücken aufweisen kann. Ein lückenloser Schutz der Daten vor dem Zugriff durch Dritte ist nicht möglich.<br>
        Der Nutzung von im Rahmen der Impressumspflicht veröffentlichten Kontaktdaten durch Dritte zur Übersendung von nicht ausdrücklich angeforderter Werbung und Informationsmaterialien wird hiermit ausdrücklich widersprochen. Die Betreiber der Seiten behalten sich ausdrücklich rechtliche Schritte im Falle der unverlangten Zusendung von Werbeinformationen, etwa durch Spam-Mails, vor.
      </p>
    </div>
  </div>
</section>
"@
}

function Build-DatenschutzSection {
  $today = Get-Date -Format "dd.MM.yyyy"

  return @"
<section class="code-section bg-[#F5F7FA] py-20 lg:py-28">
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="bg-white rounded-3xl shadow-xl border border-[#E8E8EA] p-8 lg:p-12">
      <h1 class="text-3xl md:text-4xl font-bold text-[#1D1D1F] mb-3" style="font-family: var(--font-family-heading);">Datenschutzerklärung</h1>
      <p class="text-sm text-[#6C757D] mb-10">Stand: $today</p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">1. Verantwortlicher</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        City Fahrschule Gaildorf GmbH<br>
        Karlstr. 6<br>
        74405 Gaildorf<br><br>
        Vertreten durch: Herrn Salih Kolubüyük<br>
        Telefon: +49 (0) 162 3745772<br>
        E-Mail: $contactEmail
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">2. Allgemeine Hinweise zur Datenverarbeitung</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Wir verarbeiten personenbezogene Daten nur im Rahmen der gesetzlichen Vorgaben, insbesondere der Datenschutz-Grundverordnung (DSGVO), des Bundesdatenschutzgesetzes (BDSG) und des Telekommunikation-Digitale-Dienste-Datenschutz-Gesetzes (TDDDG).<br>
        Personenbezogene Daten sind alle Daten, mit denen du persönlich identifiziert werden kannst.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">3. Hosting und Server-Log-Dateien</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Beim Aufruf unserer Website können durch den Hosting-Provider technische Zugriffsdaten (z. B. IP-Adresse, Datum/Uhrzeit, aufgerufene Seite, Browser, Betriebssystem) in Server-Log-Dateien verarbeitet werden.<br>
        Die Verarbeitung erfolgt zur Gewährleistung von Stabilität und Sicherheit der Website (Art. 6 Abs. 1 lit. f DSGVO).<br>
        Die Log-Daten werden nur so lange gespeichert, wie es für Sicherheits- und Nachweiszwecke erforderlich ist.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">4. Kontaktaufnahme (Telefon, E-Mail, Anmeldung)</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Wenn du uns kontaktierst (z. B. per Telefon, E-Mail oder über das Anmeldeformular), verarbeiten wir deine Angaben zur Bearbeitung deiner Anfrage und für Anschlussfragen.<br>
        Im Anmeldeformular werden z. B. Name, Anschrift, Telefonnummer, E-Mail-Adresse und Führerscheinklasse abgefragt.<br>
        Rechtsgrundlagen sind Art. 6 Abs. 1 lit. b DSGVO (vorvertragliche Kommunikation), Art. 6 Abs. 1 lit. a DSGVO (Einwilligung) und Art. 6 Abs. 1 lit. f DSGVO (effiziente Bearbeitung von Anfragen).
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">5. WhatsApp-Kontakt</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Wenn du den WhatsApp-Button nutzt, wirst du zu WhatsApp weitergeleitet. Dabei können personenbezogene Daten (z. B. Telefonnummer, Kommunikationsinhalte, Meta-Daten) durch WhatsApp verarbeitet werden.<br>
        Die Nutzung erfolgt freiwillig. Rechtsgrundlage ist Art. 6 Abs. 1 lit. a DSGVO (Einwilligung durch aktive Nutzung).<br>
        Es kann zu einer Übermittlung in Drittländer kommen.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">6. Externe Inhalte und Drittanbieter</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Auf dieser Website werden externe Dienste bzw. Inhalte genutzt (z. B. Google Fonts, Font Awesome, externe Bildquellen sowie Links zu Google-Diensten wie Rezensionen oder Karten).<br>
        Dabei kann es technisch erforderlich sein, dass deine IP-Adresse an den jeweiligen Anbieter übermittelt wird.<br>
        Rechtsgrundlagen sind Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an einer funktionalen und einheitlichen Darstellung) sowie – soweit erforderlich – Art. 6 Abs. 1 lit. a DSGVO in Verbindung mit § 25 TDDDG.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">7. Cookies und ähnliche Technologien</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Soweit durch diese Website Informationen auf deiner Endeinrichtung gespeichert oder ausgelesen werden, erfolgt dies ausschließlich im Rahmen der gesetzlichen Vorgaben des § 25 TDDDG.<br>
        Nicht technisch erforderliche Cookies/Technologien dürfen nur mit deiner Einwilligung eingesetzt werden.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">8. Empfänger personenbezogener Daten</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Eine Weitergabe erfolgt nur, wenn sie rechtlich zulässig ist. Empfänger können insbesondere technische Dienstleister (Hosting, IT), Kommunikationsdienste sowie ggf. öffentliche Stellen bei gesetzlicher Verpflichtung sein.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">9. Drittlandübermittlung</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Sofern Daten an Anbieter mit Sitz außerhalb der EU/des EWR übermittelt werden, erfolgt dies nur unter Beachtung der Art. 44 ff. DSGVO (z. B. Angemessenheitsbeschluss oder geeignete Garantien wie Standardvertragsklauseln).
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">10. Speicherdauer</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Wir speichern personenbezogene Daten nur so lange, wie es für die jeweiligen Zwecke erforderlich ist oder gesetzliche Aufbewahrungspflichten bestehen.<br>
        Daten aus Anfragen werden gelöscht, sobald die Bearbeitung abgeschlossen ist und keine gesetzlichen Aufbewahrungspflichten entgegenstehen.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">11. Deine Rechte</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Du hast nach Maßgabe der DSGVO insbesondere folgende Rechte: Auskunft (Art. 15 DSGVO), Berichtigung (Art. 16 DSGVO), Löschung (Art. 17 DSGVO), Einschränkung der Verarbeitung (Art. 18 DSGVO), Datenübertragbarkeit (Art. 20 DSGVO), Widerspruch (Art. 21 DSGVO) sowie Widerruf erteilter Einwilligungen mit Wirkung für die Zukunft (Art. 7 Abs. 3 DSGVO).
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">12. Beschwerderecht bei einer Aufsichtsbehörde</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Du hast gemäß Art. 77 DSGVO das Recht auf Beschwerde bei einer Datenschutzaufsichtsbehörde.<br>
        Zuständig für Baden-Württemberg ist:<br><br>
        Der Landesbeauftragte für den Datenschutz und die Informationsfreiheit Baden-Württemberg<br>
        Postfach 10 29 32, 70025 Stuttgart<br>
        oder: Heilbronner Straße 35, 70191 Stuttgart<br>
        E-Mail: poststelle@lfdi.bwl.de<br>
        Website: https://www.baden-wuerttemberg.datenschutz.de
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">13. Pflicht zur Bereitstellung von Daten</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Die Bereitstellung personenbezogener Daten ist grundsätzlich freiwillig. Bestimmte Angaben können jedoch erforderlich sein, damit wir deine Anfrage bearbeiten oder einen Vertrag anbahnen bzw. durchführen können.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">14. Automatisierte Entscheidungsfindung</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Eine ausschließlich automatisierte Entscheidungsfindung einschließlich Profiling im Sinne von Art. 22 DSGVO findet nicht statt.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">15. Datensicherheit</h2>
      <p class="text-[#1D1D1F] leading-relaxed mb-8">
        Wir treffen angemessene technische und organisatorische Maßnahmen, um deine Daten gegen Verlust, Missbrauch und unbefugten Zugriff zu schützen.
      </p>

      <h2 class="text-2xl font-bold text-[#1D3557] mb-3">16. Aktualisierung dieser Datenschutzerklärung</h2>
      <p class="text-[#1D1D1F] leading-relaxed">
        Wir behalten uns vor, diese Datenschutzerklärung anzupassen, damit sie stets den aktuellen rechtlichen Anforderungen entspricht oder Änderungen unserer Leistungen abbildet.
      </p>
    </div>
  </div>
</section>
"@
}

function Get-ContentForSlug {
  param([string]$Slug)

  switch -Regex ($Slug) {
    "^home$" {
      $homeBlocks = @()
      foreach ($section in $homepage.codeSections) {
        if ($section.id -eq "angebote") {
          $homeBlocks += (Build-OffersSectionFromContent)
          continue
        }
        $homeBlocks += [string]$section.html
        if ($section.id -eq "warum-wir") {
          $homeBlocks += (Build-GoogleReviewsSection)
        }
      }
      return $homeBlocks -join "`n`n"
    }
    "^anmeldung$" {
      return @(
        (Build-RegistrationSection),
        (Build-GoogleReviewsSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^impressum$" {
      return Build-ImpressumSection
    }
    "^datenschutz$" {
      return Build-DatenschutzSection
    }
    "^fuehrerscheinklassen$" {
      return @(
        $sectionsById["fuehrerscheinklassen"],
        (Build-LicenseQuickLinksSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^fuehrerscheinklassen/klasse-b$" {
      return @(
        (Build-KlasseBInfoSection),
        (Build-LicenseQuickLinksSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^fuehrerscheinklassen/klasse-be$" {
      return @(
        (Build-KlasseBEInfoSection),
        (Build-LicenseQuickLinksSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^fuehrerscheinklassen/klasse-a$" {
      return @(
        (Build-KlasseAInfoSection),
        (Build-LicenseQuickLinksSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^fuehrerscheinklassen/klasse-c$" {
      return @(
        (Build-KlasseCInfoSection),
        (Build-LicenseQuickLinksSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^fuehrerscheinklassen/b196$" {
      return @(
        (Build-B196InfoSection),
        (Build-LicenseQuickLinksSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^fuehrerscheinklassen/.+$" {
      $title = Get-FriendlyTitle -Slug $Slug
      $intro = Build-FallbackSection -Slug $Slug -Title $title
      return @($intro, $sectionsById["fuehrerscheinklassen"], $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^preise$" {
      return @($sectionsById["preise"], (Build-GoogleReviewsSection), $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^angebote$" {
      return @(
        (Build-OffersSectionFromContent),
        (Build-MediaShowcaseSectionFromContent),
        (Build-WhatsAppContactSection),
        $sectionsById["kontakt-cta"]
      ) -join "`n`n"
    }
    "^standorte$" {
      return @($sectionsById["standorte"], $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^kontakt$" {
      return @($sectionsById["standorte"], (Build-WhatsAppContactSection), (Build-GoogleReviewsSection), $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^faq$" {
      return @((Build-FaqSection), (Build-WhatsAppContactSection), $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^ablauf$" {
      return @($sectionsById["prozess"], $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^intensivkurs$" {
      return @($sectionsById["prozess"], $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^ueber-uns$" {
      return @($sectionsById["warum-wir"], (Build-GoogleReviewsSection), $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    "^jobs$" {
      return @((Build-JobsSection), $sectionsById["kontakt-cta"]) -join "`n`n"
    }
    default {
      $title = Get-FriendlyTitle -Slug $Slug
      return @((Build-FallbackSection -Slug $Slug -Title $title), $sectionsById["kontakt-cta"]) -join "`n`n"
    }
  }
}

function Apply-TextCorrections {
  param([string]$Html)

  $corrections = @(
    @{ From = "Über Uns"; To = "Über uns" },
    @{ From = "eMail-Adressen"; To = "E-Mail-Adressen" },
    @{ From = "Schicke Deine Bewerbung"; To = "Schicke deine Bewerbung" }
  )

  $output = $Html
  foreach ($rule in $corrections) {
    $output = $output.Replace($rule.From, $rule.To)
  }

  return $output
}

function Apply-HeaderBranding {
  param(
    [string]$Html,
    [string]$RelativeLogoPath
  )

  $output = [regex]::Replace($Html, '(?is)<img\b[^>]*data-logo[^>]*>', {
      param($match)
      $tag = $match.Value
      $tag = [regex]::Replace($tag, '(?i)\bsrc="[^"]*"', "src=`"$RelativeLogoPath`"")
      $tag = [regex]::Replace($tag, '(?i)\balt="[^"]*"', 'alt="City Fahrschule Gaildorf Logo"')
      # Slightly enlarge only the header logo on medium+ screens.
      $tag = [regex]::Replace($tag, '(?i)\bclass="h-20 w-auto"', 'class="h-20 md:h-24 w-auto"')
      return $tag
    })

  # Keep fixed header height and spacer in sync across devices.
  $output = $output.Replace('class="flex justify-between items-center h-24"', 'class="flex justify-between items-center h-20 md:h-24"')
  $output = $output.Replace('<div class="h-20"></div>', '<div class="h-20 md:h-24"></div>')

  return $output
}

function Apply-BrandIcons {
  param(
    [string]$Html,
    [string]$RelativeLogoPath
  )

  $output = [regex]::Replace($Html, '(?i)(<link[^>]*rel="icon"[^>]*href=")[^"]*(")', {
      param($match)
      return $match.Groups[1].Value + $RelativeLogoPath + $match.Groups[2].Value
    })

  $output = [regex]::Replace($output, '(?i)(<link[^>]*rel="apple-touch-icon"[^>]*href=")[^"]*(")', {
      param($match)
      return $match.Groups[1].Value + $RelativeLogoPath + $match.Groups[2].Value
    })

  return $output
}

function Apply-BrandColorTheme {
  param([string]$Html)

  $replacements = @(
    @{ From = "#D4AF37"; To = "#1184D1" },
    @{ From = "#C19B2C"; To = "#0F74BA" },
    @{ From = "#E63946"; To = "#0EA5E9" },
    @{ From = "#C62F3A"; To = "#0284C7" },
    @{ From = "#F77F00"; To = "#38BDF8" },
    @{ From = "#06A77D"; To = "#1184D1" },
    @{ From = "#2E7D32"; To = "#0284C7" },
    @{ From = "#1565C0"; To = "#1D4ED8" },
    @{ From = "#FFC107"; To = "#7DD3FC" },
    @{ From = "#1E3A5F"; To = "#111827" },
    @{ From = "#152A45"; To = "#0B1220" },
    @{ From = "#14263F"; To = "#0B1220" },
    @{ From = "#1D3557"; To = "#0F172A" },
    @{ From = "#0F2744"; To = "#0B1118" },
    @{ From = "#0A1D35"; To = "#070C11" },
    @{ From = "#E8EDF2"; To = "#E7EFF7" },
    @{ From = "#0F1A2E"; To = "#070C11" },
    @{ From = "#457B9D"; To = "#1D4ED8" },
    @{ From = "#FCA311"; To = "#38BDF8" },
    @{ From = "#E06800"; To = "#0284C7" },
    @{ From = "#059068"; To = "#0F74BA" },
    @{ From = "#FEF1F2"; To = "#EEF5FC" }
  )

  $output = $Html
  foreach ($entry in $replacements) {
    $output = $output.Replace($entry.From, $entry.To)
  }

  return $output
}

$allHtmlSource = @($website.headerCodeSection.html, ($homepage.codeSections | ForEach-Object { $_.html }), $website.footerCodeSection.html) -join "`n"
$rawLinks = [regex]::Matches($allHtmlSource, 'href="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }

$internalSlugs = $rawLinks |
  Where-Object { $_.StartsWith("/") } |
  ForEach-Object { $_.Trim("/") } |
  ForEach-Object { if ([string]::IsNullOrWhiteSpace($_)) { "home" } else { $_ } } |
  Sort-Object -Unique

$requiredSlugs = @(
  "home",
  "ablauf",
  "angebote",
  "anmeldung",
  "datenschutz",
  "faq",
  "fuehrerscheinklassen",
  "fuehrerscheinklassen/b196",
  "fuehrerscheinklassen/klasse-a",
  "fuehrerscheinklassen/klasse-b",
  "fuehrerscheinklassen/klasse-be",
  "fuehrerscheinklassen/klasse-c",
  "impressum",
  "intensivkurs",
  "jobs",
  "kontakt",
  "preise",
  "standorte",
  "ueber-uns"
)

$pageSlugs = @($requiredSlugs + $internalSlugs) | Sort-Object -Unique

$fontFamilies = @()
foreach ($font in $website.fonts) {
  $fontFamilies += "family=$($font -replace ' ', '+'):wght@300;400;500;600;700"
}

$fontHref = "https://fonts.googleapis.com/css2?" + ($fontFamilies -join "&") + "&display=swap"
$colorVars = @(
  "--accent-color: #1184D1;",
  "--accent2-color: #0EA5E9;",
  "--accent3-color: #1D4ED8;",
  "--accent4-color: #7DD3FC;",
  "--primary-color: #111827;",
  "--dark-text-color: #111827;",
  "--gray-text-color: #475569;",
  "--button-padding-x: 32px;",
  "--button-padding-y: 16px;",
  "--font-family-body: Inter;",
  "--light-text-color: #FFFFFF;",
  "--dark-border-color: #111827;",
  "--light-border-color: #D7E3F0;",
  "--font-family-heading: Outfit;",
  "--button-rounded-radius: 8px;",
  "--dark-background-color: #0B1118;",
  "--light-background-color: #F4F8FC;",
  "--medium-background-color: #E7EFF7;",
  "--primary-button-text-color: #FFFFFF;",
  "--secondary-button-bg-color: #0B1118;",
  "--secondary-button-text-color: #FFFFFF;",
  "--primary-button-hover-bg-color: #070C11;",
  "--primary-button-hover-text-color: #FFFFFF;",
  "--secondary-button-hover-bg-color: #070C11;",
  "--secondary-button-hover-text-color: #FFFFFF;"
) -join "`n    "
$websiteHead = if ($website.aiWebsiteHeadHtml) { [string]$website.aiWebsiteHeadHtml } else { "" }

foreach ($slug in $pageSlugs) {
  $friendlyTitle = Get-FriendlyTitle -Slug $slug
  $metaDescription = "Fahrschule City Gaildorf - $friendlyTitle"

  $pageHead = if ($slug -eq "home" -and $homepage.aiPageHeadHtml) {
    [string]$homepage.aiPageHeadHtml
  } else {
    "<title>$friendlyTitle | Fahrschule City Gaildorf</title>`n<meta name=`"description`" content=`"$metaDescription`">"
  }

  $relativeLogoPath = Get-RelativeAssetPath -FromSlug $slug -AssetRelativePath $logoRelativePath
  $headerHtml = Rewrite-Hrefs -Html ([string]$website.headerCodeSection.html) -CurrentSlug $slug
  $headerHtml = Apply-HeaderBranding -Html $headerHtml -RelativeLogoPath $relativeLogoPath
  $footerHtml = Rewrite-Hrefs -Html ([string]$website.footerCodeSection.html) -CurrentSlug $slug
  $footerHtml = Apply-HeaderBranding -Html $footerHtml -RelativeLogoPath $relativeLogoPath
  $rawMainContent = if ($slug -eq "jobs") {
    @((Build-JobsSection), $sectionsById["kontakt-cta"]) -join "`n`n"
  } else {
    Get-ContentForSlug -Slug $slug
  }
  $mainContent = Rewrite-Hrefs -Html $rawMainContent -CurrentSlug $slug
  $mainContent = Rewrite-AssetAttributes -Html $mainContent -CurrentSlug $slug

  $finalHtml = @"
<!doctype html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex,nofollow">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="$fontHref" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
  $websiteHead
  $pageHead
  <style>
    :root {
    $colorVars
    }
    * { box-sizing: border-box; }
    html { scroll-behavior: smooth; }
    body {
      margin: 0;
      font-family: var(--font-family-body, Inter), sans-serif;
      color: var(--dark-text-color, #1D1D1F);
      background: var(--light-background-color, #F5F7FA);
    }
    img { max-width: 100%; height: auto; }
    header, main, footer { overflow-x: clip; }
    .code-section { overflow-x: clip; }
    @media (max-width: 1024px) {
      input, select, textarea {
        font-size: 16px;
      }
    }
    @media (max-width: 1024px) {
      main [class*="lg:text-6xl"] { font-size: 2.8rem !important; line-height: 1.15 !important; }
      main [class*="lg:text-5xl"] { font-size: 2.35rem !important; line-height: 1.18 !important; }
      main [class*="py-20"] { padding-top: 4rem !important; padding-bottom: 4rem !important; }
      main [class*="lg:py-28"] { padding-top: 5rem !important; padding-bottom: 5rem !important; }
    }
    @media (max-width: 640px) {
      main [class*="text-6xl"] { font-size: 2.05rem !important; line-height: 1.15 !important; }
      main [class*="text-5xl"] { font-size: 1.75rem !important; line-height: 1.2 !important; }
      main [class*="text-4xl"] { font-size: 1.45rem !important; line-height: 1.25 !important; }
      main [class*="py-20"] { padding-top: 3.25rem !important; padding-bottom: 3.25rem !important; }
      main [class*="lg:py-28"] { padding-top: 3.75rem !important; padding-bottom: 3.75rem !important; }
      main [class*="w-24"][class*="h-24"] { width: 4.25rem !important; height: 4.25rem !important; }
      main [class*="w-20"][class*="h-20"] { width: 3.75rem !important; height: 3.75rem !important; }
      main [class*="sm:flex-row"] > a.inline-flex,
      main [class*="sm:flex-row"] > button.inline-flex {
        width: 100%;
      }
      #global-header [data-landingsite-mobile-menu] a {
        min-height: 44px;
        display: flex;
        align-items: center;
      }
    }
    .whatsapp-float {
      position: fixed;
      right: 18px;
      bottom: 18px;
      width: 58px;
      height: 58px;
      border-radius: 9999px;
      background: #25D366;
      color: #fff;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 12px 24px rgba(0, 0, 0, 0.25);
      z-index: 70;
      transition: transform 0.2s ease, background-color 0.2s ease;
    }
    .whatsapp-float:hover {
      transform: translateY(-2px);
      background: #1EBE5A;
    }
    .whatsapp-float i {
      font-size: 30px;
      line-height: 1;
    }
    @media (max-width: 640px) {
      .whatsapp-float {
        width: 54px;
        height: 54px;
        right: 14px;
        bottom: 14px;
      }
      .whatsapp-float i { font-size: 28px; }
    }
  </style>
</head>
<body class="[font-family:var(--font-family-body)]">
$headerHtml

<main>
$mainContent
</main>

$footerHtml

<a href="$whatsAppLink" target="_blank" rel="noopener noreferrer" class="whatsapp-float" aria-label="WhatsApp Kontakt öffnen" title="WhatsApp">
  <i class="fa-brands fa-whatsapp" aria-hidden="true"></i>
</a>

<script>
  (() => {
    const button = document.querySelector('[data-landingsite-mobile-menu-toggle]');
    const menu = document.querySelector('[data-landingsite-mobile-menu]');
    if (button && menu) {
      button.addEventListener('click', () => menu.classList.toggle('hidden'));
      menu.querySelectorAll('a').forEach((link) => {
        link.addEventListener('click', () => menu.classList.add('hidden'));
      });
    }

    const form = document.getElementById('anmeldung-form');
    if (!form) return;

    const feedback = document.getElementById('anmeldung-feedback');
    form.addEventListener('submit', (event) => {
      event.preventDefault();
      if (!form.reportValidity()) return;

      const formData = new FormData(form);
      const bodyLines = [
        'Neue Anmeldung über die Webseite',
        '',
        'Name: ' + (formData.get('name') || ''),
        'Anschrift: ' + (formData.get('anschrift') || ''),
        'Telefonnummer: ' + (formData.get('telefon') || ''),
        'E-Mail: ' + (formData.get('email') || ''),
        'Führerscheinklasse: ' + (formData.get('fuehrerscheinklasse') || ''),
        'Nachricht: ' + (formData.get('nachricht') || '')
      ];

      const subject = encodeURIComponent('Neue Anmeldung - Fahrschule City Gaildorf');
      const body = encodeURIComponent(bodyLines.join('\n'));
      window.location.href = 'mailto:${contactEmail}?subject=' + subject + '&body=' + body;

      if (feedback) {
        feedback.textContent = 'Vielen Dank. Dein E-Mail-Programm wurde mit den eingegebenen Daten geöffnet.';
        feedback.classList.remove('hidden');
      }
    });
  })();
</script>
</body>
</html>
"@

  $finalHtml = Apply-BrandIcons -Html $finalHtml -RelativeLogoPath $relativeLogoPath
  $finalHtml = Apply-BrandColorTheme -Html $finalHtml
  $finalHtml = Apply-TextCorrections -Html $finalHtml

  # Encode sharp-s defensively so it renders correctly regardless of file encoding.
  $finalHtml = $finalHtml -replace "ß", "&szlig;"

  $targetPath = Get-PageFilePath -Slug $slug
  Set-Content -LiteralPath $targetPath -Value $finalHtml -Encoding UTF8
}

Write-Output "Generated pages: $($pageSlugs.Count)"
foreach ($slug in $pageSlugs) {
  if ($slug -eq "home") {
    Write-Output " - / -> index.html"
  } else {
    Write-Output " - /$slug -> $slug/index.html"
  }
}
