# 🏆 Torneo di Lozzo 2026 — Documentazione Tecnica & Guida Utente

Benvenuto nel repository ufficiale del **Torneo di Lozzo 2026**. 
Questa applicazione web/mobile-first, sviluppata in **Flutter**, permette la gestione e la consultazione in tempo reale di un torneo di calcio amatoriale che si terrà il **4–5 Luglio 2026**.

Il sistema è configurato per aggiornarsi istantaneamente: ogni volta che un amministratore inserisce un gol o modifica una squadra dal proprio dispositivo, tutti gli utenti connessi vedono gli aggiornamenti sul proprio schermo senza dover ricaricare la pagina.

---

## 🛠️ Stack Tecnico & Dipendenze

L'applicazione è costruita sul seguente stack tecnologico:
* **Framework**: Flutter 3.x (Dart 3.x)
* **Piattaforma di Target Primaria**: Web (Chrome) con supporto Responsive per dispositivi mobili
* **State Management**: `Provider` + `ChangeNotifier` (gestione reattiva dello stato globale dell'app)
* **Database Cloud**: **Firebase Firestore** per la sincronizzazione in tempo reale
* **Persistenza Locale**: `SharedPreferences` (per memorizzare le impostazioni locali dell'Admin, come il PIN crittografato sul dispositivo)
* **Hosting**: **GitHub Pages** con integrazione CI/CD (automazione dei rilasci)

### Dipendenze principali (`pubspec.yaml`)
* `firebase_core: ^3.1.1`: Inizializzazione della connessione con i servizi Google Firebase.
* `cloud_firestore: ^5.0.1`: Gestione dei listener e delle operazioni CRUD in tempo reale sul database NoSQL.
* `provider: ^6.1.0`: State-management centrale per distribuire i dati e notificare i widget al variare dei dati.
* `shared_preferences: ^2.2.0`: Per salvare localmente impostazioni sensibili (come il PIN Admin).
* `url_launcher: ^6.2.5`: Gestione di eventuali collegamenti ipertestuali esterni.

---

## 🏗️ Architettura del Codice (`lib/`)

L'applicazione segue una struttura pulita e modulare:

```text
lib/
├── main.dart                  # Inizializza Firebase e avvia la TournamentShell (lo scheletro dell'interfaccia)
├── firebase_options.dart      # Credenziali di accesso e puntamento al progetto Firebase Cloud
├── data/
│   └── initial_data.dart      # Squadre e partite predefinite usate per il primo avvio (seeding)
├── models/
│   ├── team.dart              # Struttura dati Squadra e elenco giocatori
│   ├── player.dart            # Modello del Giocatore (nome, numero di maglia)
│   ├── match_model.dart       # Stato partita (sched, live, done), punteggi e marcatori
│   ├── scorer.dart            # Evento del gol (minuto, autore, autogol)
│   └── standing_row.dart      # Modello riga di classifica generata a runtime
├── providers/
│   └── tournament_provider.dart  # Cuore logico: ascolta Firestore in streaming e applica i metodi di scrittura
├── screens/
│   ├── live_screen.dart       # Tab 1: Partite in corso, pannello admin per avvio e fine gara, e prossimi match
│   ├── standings_screen.dart  # Tab 2: Classifiche gironi con form status (V/P/S) e scontri diretti
│   ├── scorers_screen.dart    # Tab 3: Classifica cannonieri (top 15) calcolata a runtime ordinando i gol
│   ├── results_screen.dart    # Tab 4: Storico delle partite concluse suddivise per giorno
│   ├── bracket_screen.dart    # Tab 5: Fase finale ad eliminazione diretta (generazione automatica accoppiamenti)
│   └── teams_screen.dart      # Tab 6: Gestione squadre, aggiunta/rimozione giocatori e pulsante di Reset totale
├── theme/
│   └── app_theme.dart         # Design System: Colori Tailwind mappati in Flutter, gradienti dei badge e stili testo
├── utils/
│   ├── standings_calculator.dart  # Algoritmo matematico per calcolo punti, gol fatti/subiti e DR
│   └── scorers_calculator.dart    # Algoritmo per estrarre l'elenco cannonieri aggregando i gol di ogni match
└── widgets/
    ├── team_badge.dart        # Stemma squadra circolare con gradiente personalizzato
    ├── live_dot.dart          # Indicatore pulsante LIVE con animazione ad onda pulsante (Ping)
    ├── admin_modal.dart       # Schermata di inserimento PIN con tastierino integrato ed effetto vibrazione in caso di errore
    ├── goal_panel.dart        # Pannello per inserire i gol scegliendo il marcatore dalla rosa o l'opzione autogol
    └── welcome_cover.dart     # Splash screen iniziale di benvenuto animata
```

---

## ⚡ Configurazione & Architettura Firebase

Il database è ospitato su **Google Firebase** ed è configurato in modalità Serverless in tempo reale.

### 1. Creazione del Database
* **Servizio**: Cloud Firestore (Database NoSQL orientato ai documenti)
* **ID Database**: `(default)` (essenziale per l'auto-scoperta da parte di Flutter)
* **Località**: `europe-west12` (Torino, Italia) per garantire tempi di latenza inferiori ai 30ms sul territorio nazionale
* **Piano di Fatturazione**: Blaze (Pay-as-you-go), protetto dalla soglia gratuita giornaliera (0€ di costo effettivo sotto i 50k read/day)

### 2. Struttura dei Dati (Collezioni)
Firestore è organizzato in due collezioni principali alla radice:
1. **`teams`**: Contiene documenti identificati dall'ID numerico della squadra (es: `1`, `2`...). Ogni documento memorizza il nome, il gruppo del girone, il colore grafico del badge e la lista JSON dei giocatori con numero di maglia.
2. **`matches`**: Contiene documenti identificati dall'ID della partita (es: `A1`, `QF1`...). Memorizza le squadre, lo stato corrente (`sched` = programmata, `live` = in corso, `done` = conclusa), i gol, il minuto e l'array cronologico dei gol inseriti (`scorers`).

### 3. Logica di Seeding Automatico
Nel file `tournament_provider.dart`, all'avvio dell'app viene effettuato un controllo:
* Se la collezione `teams` o `matches` su Firestore risulta vuota (es. al primissimo avvio), l'app esegue una procedura di **Seeding**.
* Tramite operazioni in `WriteBatch`, preleva i dati originari definiti in `initial_data.dart` e li carica su Firebase. In questo modo il database non rimane mai orfano.

### 4. Regole di Sicurezza (Firestore Rules)
Per consentire il corretto funzionamento dell'applicazione senza costringere gli utenti spettatori a registrarsi con username e password, le regole di Firestore (scheda **Rules** sulla console) sono configurate per l'accesso pubblico controllato:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 🚀 Ciclo di Rilascio CI/CD (GitHub Pages)

La pubblicazione dell'applicazione è completamente automatizzata e non richiede l'installazione di alcun software o riga di comando locale per il deploy.

### 1. Impostazione dell'Identità Git
Per inviare correttamente le modifiche dal proprio computer ed essere riconosciuti da GitHub, configurare la propria identità da terminale:
```bash
git config --global user.name "il-tuo-username"
git config --global user.email "tua-email@esempio.com"
```

### 2. Workflow di Pubblicazione (`gh-deploy.yml`)
Ogni volta che viene effettuato un `push` sul ramo principale (`main` o `master`), GitHub avvia un'operazione automatica (visibile nella scheda **Actions** del repository):
1. **Ambiente virtuale**: Avvia un container Linux Ubuntu.
2. **Setup SDK**: Installa in automatico Flutter stabile.
3. **Build**: Esegue la compilazione di produzione:
   `flutter build web --base-href "/Torneo_Lozzo_2026/"`
4. **Deploy**: Preleva la cartella compilata `build/web` e la pubblica sul ramo speciale `gh-pages`.

Il sito web aggiornato è immediatamente raggiungibile all'indirizzo:
🔗 **[https://mikzanco.github.io/Torneo_Lozzo_2026/](https://mikzanco.github.io/Torneo_Lozzo_2026/)**

---

## 💻 Sviluppo & Test in Locale

Se desideri apportare modifiche al codice sul tuo computer e provarle prima di caricarle online:

1. **Assicurati che non ci siano errori di sintassi** eseguendo:
   ```bash
   flutter analyze
   ```
2. **Avvia il server di sviluppo su Chrome** (sostituendo il percorso di Flutter se non presente nel PATH di sistema):
   ```bash
   /Users/cristianadezolt/Documents/flutter/bin/flutter run -d chrome
   ```
3. **Modalità Sviluppatore / Caching**:
   Se noti che Chrome mostra una schermata vecchia o non riflette le modifiche appena inviate, apri una **finestra in incognito** o svuota i dati del sito tramite gli Strumenti per Sviluppatori (`F12` / `Cmd + Option + I` -> *Application* -> *Clear Site Data*).

---

## 🔑 Gestione Amministratore (Admin Mode)

* **Accesso**: Clicca sul lucchetto 🔒 in alto a destra.
* **PIN di Default**: **`123456`**
* **Funzioni Admin**:
  * **Fase Gironi**: Avviare le partite e inserire i gol (con marcatore o autogol). Terminando la partita la classifica si aggiorna istantaneamente.
  * **Fase Finale (Eliminazione diretta)**: Al termine dei gironi, l'Admin può cliccare sul tab *Tabellone* e premere **Genera Tabellone**. Il sistema calcola automaticamente gli accoppiamenti (1° contro 4°, 2° contro 3°) e posiziona le squadre. Le successive semifinali e finali si popolano dinamicamente man mano che si terminano i quarti di finale.
  * **Reset Torneo**: Nel tab **⚙️ Squadre**, in fondo alla pagina, l'Admin ha a disposizione il tasto **RESETTA TUTTO IL TORNEO** per ripulire interamente il database Firebase e ricominciare da zero (punteggi 0-0 e partite da disputare).
