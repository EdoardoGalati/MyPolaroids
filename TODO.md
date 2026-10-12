# TODO — Edoardo / Instant Box

## Idee
- Verificare catalogo su polaroid.com con Chrome (estensione non ha permesso per polaroid.com, abilitarlo).
- Il foglio "Take Shots" lascia trasparire il bottone nero del dettaglio attraverso il material. Valutare presentationBackground.
- Screenshot tour: MyPolaroidsUITests/ScreenshotTour.swift scrive PNG in /tmp/ib-shots. Tenere aggiornato se cambiano i label.
- Vecchi pacchi salvati con nomi catalogo vecchi ("Black & White", "Color Black Frame"): ora matchano via normalizzazione in FilmPackColors; controllare su dati reali.
- Widget: cartella MyPolaroidsWidgetExtension esiste ma non è nel progetto. Finire o cancellare.
- Icona in formato .icon (Icon Composer) come Stories.
- Warning: 3 stringhe privacy vuote in Info.plist (NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSPhotoLibraryAddUsageDescription). Blocco review.
- Deployment target: 16.6 nel progetto, 26.0 su un target. Allineare.
- Rinominare repo GitHub MyPolaroids in InstantBox (deciso: no, per ora).

## Pronte
- [ ] Push e pubblicazione catalogo
  - Cosa: push di Final-Post-iCloud e di main su GitHub. GitHub Pages serve main, l'app scarica da edoardogalati.github.io/MyPolaroids/. Poi in app: Settings > tocca Version 3 volte > Data > Refresh now.
  - Fatto quando: edoardogalati.github.io/MyPolaroids/camera_models.json risponde con 96 camere e la lista Add Camera in app mostra "Mod" e "Go Generation 3".

## In corso / Fatte
- [x] Redesign nativo iOS 27 (2026-10-12)
- [x] Catalogo camere e film aggiornato 2026: 96 camere, 44 film, 7 formati (2026-10-12)
- [x] Build con Xcode 27: RevenueCat 5.95, scheme condiviso, build/ ignorata (2026-10-12)
- [x] Ripristino 1.3 build 13 da iCloud (2026-10-12)
