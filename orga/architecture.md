# Version 1 (V1)

## Dark Mode *(3/10)* → **2 Tage**
- Einstellbar im Tab "Einstellungen":
  - Light
  - Dark
  - System

## Theming Architektur *(1/10)* → **0,5 Tage**

## Firebase Einrichtung *(5/10)* → **1 Tag**

## Authentifizierung *(7/10)* → **6 Tage**
- Login  
- Logout  
- Passwort vergessen  
- Registrieren  
- Automatisches Login/Logout  
- Als Gast fortfahren
- Passwort zurücksetzen

## Lizenzkosten umgehen *(2/10)* → **0,5 Tage**
- Welche Features pro Version benötigt werden

## Datenbank *(7/10)* → **fortlaufend**
- Userdaten
- Events als Markdown oder Json
- Gebetszeiten als csv

## Organisation Ordnerstruktur *(1/10)* → **0,5 Tage**

- assets 

  -> fonts

  -> icons 

  -> images 

  -> logos 
  
  -> links 

- utils  

  - constants

    -> colors

    -> sizes

    -> text_strings

    -> image_strings


  - theme

    -> textFieldTheme

    -> textTheme

    -> outlinedButtonTheme

    -> theme.dart

- components

  -> textfields

  -> buttons

- helpers

  -> zB: bool isDarkMode()

- pages

  -> prayerTime

  -> projects

  -> More

  -> ArabicSchool


## Pages

### Gebetszeiten *(6/10)* → **5 Tage**
- Beispiel-API:  
  `https://mawaqit.net/api/2.0/mosque/search?word=bbf&fields=slug,label`
- Iqama: *(?/10)*
- Khutba

### Projekte / Events *(6/10)* → **5 Tage**

### Weitere Seiten *(3/10)* → **5 Tage**
- AGB (rechtliches)  
- Über uns (Verein, Mission, Vorstand, Kontakt, Spendenlinks)  
- Arabische Schule (Informationen)

## Begrüßungsbildschirm *(1/10)* → **1 Tag**

## Downloads *(7/10)* → **4–5 Tage**
- Gebetszeiten für den Monat als PDF

## Tools kennenlernen → **fortlaufend**
- Flow  
- Firebase  
- Übersetzungstools  
- Theming  
- Downloader  
- Requests / API Calls  
- Benachrichtigungen  
- Routing  

## Server Einrichtung *(10/10)* → **fortlaufend**
- PDFs ablegen  
- CI/CD (DevOps) *(optional)*

---

# Version 2 (V2)

## Authentifizierung (fortgeführt)
- User Management *(10/10)* → **fortlaufend**
  - Mitglieder (für exklusive Inhalte)  
  - Admins (Blogposts erstellen)

## Pages

### Kalender
- Webview *(1/10)* → **1 Tag**  
- Vollständige Implementierung *(9/10)* → **10–14 Tage**

### Arabische Schule *(9/10)* → **? Tage**
- Anmeldung, Tagesprogramm, etc.

### Einstellungen *(8/10)* → **? Tage**
- Benachrichtigungseinstellungen  
- Erinnerungen vor Gebetszeiten

## Reporting

- User-Messaging bei Errors oder Erfolgen *(4/10)* → **2–3 Tage**  
- Benachrichtigungen *(5/10)* → **? Tage**

## Widget in Benachrichtigungsumgebung *(?/10)* → **? Tage**
- Vergleichbar mit Azan Time Pro

## Übersetzungen *(7/10)* → **? Tage**
- Sprachdateien, Platzhalter

## Server Einrichtung
- Automatisierte Generierung von Blogposts *(9/10)* → **10–14 Tage**

---

## TODO

- UI-Skizzen und Design (gemeinsam)
- Tools kennenlernen (erst selbstständig, dann Abgleich)
- Projekt aufräumen und auf GitHub pushen (`.gitignore`) *(Emre)*
- Ordnerstruktur anlegen (gemeinsam)
- Utilities definieren (Designstruktur, Dark/Light Mode, Theming, Standardkomponenten wie Buttons, Textfelder)
- Firebase einrichten (erst jeder selbst, dann gemeinsamer Abgleich)
