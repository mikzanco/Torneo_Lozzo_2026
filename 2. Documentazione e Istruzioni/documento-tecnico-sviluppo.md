# Documento Tecnico di Sviluppo — Torneo di Lozzo 2026

Questo documento descrive in dettaglio tutte le implementazioni tecniche realizzate per l'applicazione web del **Torneo di Lozzo 2026**, incluse le procedure di configurazione, la migrazione a Firebase Firestore per la sincronizzazione in tempo reale, il ciclo di deploy continuo con GitHub Pages e l'integrazione del regolamento ufficiale del calcio a 5 (Futsal).

---

## 1. Migrazione a Firebase Firestore (Real-Time Sync)

Per permettere l'aggiornamento istantaneo del torneo tra i vari dispositivi connessi senza ricaricare la pagina, l'applicazione è stata migrata da un modello di dati locale a **Google Firebase Firestore**.

### Procedure Effettuate:
1. **Configurazione Firebase Web**:
   * Creazione del progetto Firebase `torneo-lozzo-2026`.
   * Inizializzazione del database **Cloud Firestore** in modalità test nella regione `europe-west12` (Torino, Italia).
   * Generazione del file `lib/firebase_options.dart` contenente le credenziali d'accesso (API Key, Project ID, App ID, ecc.).
2. **Inizializzazione**:
   * Aggiornamento del [main.dart](file:///Users/cristianadezolt/Desktop/progetto%20Michele/VSC%20+%20Flutter/lib/main.dart) per garantire l'inizializzazione asincrona di Firebase prima del montaggio dei widget (`WidgetsFlutterBinding.ensureInitialized()`).
3. **Refactoring del Provider** ([tournament_provider.dart](file:///Users/cristianadezolt/Desktop/progetto%20Michele/VSC%20+%20Flutter/lib/providers/tournament_provider.dart)):
   * Sostituzione delle variabili locali con `StreamSubscription` che ascoltano in tempo reale le collezioni `teams` e `matches` di Firestore.
   * Implementazione del seeding automatico: se all'avvio il database Firestore è vuoto, i dati iniziali presenti in `lib/data/initial_data.dart` vengono scritti in blocco (`WriteBatch`) su Firestore.
   * Modifica di tutte le azioni di scrittura (`addGoal`, `updateFouls`, `startMatch`, `endMatch`, `resetTournament`) in operazioni asincrone dirette verso Firestore.

---

## 2. Configurazione e Rilascio CI/CD (GitHub Pages)

La pubblicazione dell'applicazione è gestita tramite una pipeline automatica di integrazione e rilascio continuo (CI/CD).

### Procedure Effettuate:
1. **Repository Git**:
   * Collegamento del codice sorgente al repository GitHub remoto: `https://github.com/mikzanco/Torneo_Lozzo_2026.git`.
2. **Pipeline GitHub Actions**:
   * Configurazione del file `.github/workflows/gh-deploy.yml` che si attiva automaticamente ad ogni push sul ramo `main`.
   * Il workflow esegue i seguenti passaggi su un container Ubuntu:
     1. Installazione dell'SDK di Flutter (versione stabile).
     2. Risoluzione delle dipendenze di progetto (`flutter pub get`).
     3. Compilazione di produzione per il web specificando il percorso base: `flutter build web --base-href "/Torneo_Lozzo_2026/"`.
     4. Distribuzione automatica della cartella compilata `build/web` sul ramo `gh-pages` tramite l'azione `JamesIves/github-pages-deploy-action`.
   * Il sito live è accessibile a tutti all'indirizzo: **[https://mikzanco.github.io/Torneo_Lozzo_2026/](https://mikzanco.github.io/Torneo_Lozzo_2026/)**.

---

## 3. Implementazione Regolamento Ufficiale Futsal (Calcio a 5)

Sono state apportate modifiche approfondite alla logica dell'applicazione per supportare i criteri di classificazione dei gironi e i meccanismi della fase finale ad eliminazione diretta, inclusi i tempi supplementari, i calci di rigore e il limite dei falli cumulativi.

### A. Classifica dei Gironi (Tiebreakers)
Nel file [standings_calculator.dart](file:///Users/cristianadezolt/Desktop/progetto%20Michele/VSC%20+%20Flutter/lib/utils/standings_calculator.dart), l'algoritmo di ordinamento `calcStandings` è stato aggiornato per applicare rigidamente i seguenti criteri in ordine di priorità:
1. **Punti totali** (3 per vittoria, 1 per pareggio, 0 per sconfitta).
2. **Caso di 2 squadre a pari punti**: *Scontro diretto* (la vincente dello scontro diretto si posiziona davanti).
3. **Caso di 3 o più squadre a pari punti**: *Classifica Avulsa* (mini-classifica considerando solo le partite giocate tra le squadre a pari punti):
   * Punti accumulati nei soli scontri diretti.
   * Differenza reti nei soli scontri diretti.
   * Reti segnate nei soli scontri diretti.
4. **Criteri generali residuali**:
   * Differenza reti totale nel girone.
   * Gol totali segnati nel girone.
   * Sorteggio (gestito tramite ordinamento ID o ordine casuale stabile).

### B. Tabellone a 5 Fasi
Per risolvere il bug strutturale del tabellone precedente (che passava dagli 8 accoppiamenti iniziali direttamente alle semifinali, perdendo 4 squadre), è stata inserita fisicamente la fase dei **Quarti di Finale**.
La nuova struttura a 5 fasi genera e visualizza:
1. **Ottavi di Finale** (`OT1` a `OT8`): 16 squadre qualificate dai gironi (le prime 4 di ciascuno dei 4 gironi A, B, C, D).
2. **Quarti di Finale** (`QF1` a `QF4`): 8 squadre vincenti dagli Ottavi.
3. **Semifinali** (`SF1` e `SF2`): 4 squadre vincenti dai Quarti.
4. **Finale 3°/4° posto** (`F3`): disputata tra le due perdenti delle Semifinali.
5. 🏆 **Finale** (`F`): disputata tra le due vincenti delle Semifinali.

### C. Risoluzione Pareggi nella Fase KO
1. **Ottavi di Finale**: In caso di pareggio al termine del tempo regolamentare, non si disputano tempi supplementari né rigori. Passa la squadra meglio classificata nella fase a gironi (che per accoppiamento risiede sempre nello slot in casa).
2. **Dai Quarti in poi**: In caso di pareggio, il regolamento prevede:
   * **Tempi Supplementari**: Un tempo supplementare di 5 minuti con la regola del **Golden Goal** (chi segna per primo vince immediatamente la partita).
   * **Calci di Rigore**: In caso di persistenza del pareggio oltre i 5 minuti supplementari, si procede ai calci di rigore (3 rigori per squadra, seguiti da rigori ad oltranza in caso di ulteriore parità).

*La logica è gestita in [tournament_provider.dart](file:///Users/cristianadezolt/Desktop/progetto%20Michele/VSC%20+%20Flutter/lib/providers/tournament_provider.dart) nel metodo `_endBracketMatch` che controlla la presenza di rigori salvati per calcolare il corretto vincitore e avanzarlo nella fase successiva.*

### D. Limite Falli Cumulativi
Durante le partite ad eliminazione diretta, ciascuna squadra ha un limite di **5 falli** concessi. Dal 6° fallo in poi viene assegnato un **tiro libero** dal dischetto speciale (senza barriera e senza possibilità di ribattuta in caso di respinta).
* **UI Live Card** ([live_card.dart](file:///Users/cristianadezolt/Desktop/progetto%20Michele/VSC%20+%20Flutter/lib/widgets/live_card.dart)):
  * Se una squadra ha accumulato **5 falli**, compare una notifica gialla: `⚠️ Bonus esaurito [Squadra]: Prossimo fallo Tiro Libero`.
  * Se una squadra commette **6 o più falli**, la notifica lampeggia in rosso: `🚨 TIRO LIBERO per ogni fallo commesso da [Squadra]!`.

### E. Pannello di Controllo Admin & Visualizzazione Punteggi
* **Inserimento Dati**: Per le partite dai Quarti in poi, l'interfaccia Admin mostra un interruttore per attivare lo stato **Supplementari (D.T.S.)** e un selettore per inserire il punteggio dei **Rigori**.
* **Validazione di Sicurezza**: Il pulsante "Termina Partita" valida il risultato. Se si tenta di chiudere una partita dei Quarti/Semi/Finale finita in pareggio senza aver prima inserito il punteggio dei rigori, il sistema impedisce il salvataggio e mostra un avviso a schermo per evitare il blocco dei passaggi del tabellone.
* **Visualizzazione Spettatore**: Gli utenti vedono l'etichetta `D.T.S. (Golden Goal)` e il risultato dei rigori in piccolo sotto il punteggio principale (es. `Rigori: 3 – 4` nella card live, o `3 (2) – 3 (3)` nel tabellone KO).

---

## 4. Procedure Operative per l'Admin

### Inizio di un nuovo Torneo (Reset)
1. Accedere al pannello Admin inserendo il PIN nella barra in alto.
2. Navigare alla scheda **Squadre**.
3. Scorrere fino in fondo e cliccare su **RESETTA TUTTO IL TORNEO**. Questa procedura pulisce interamente il database Firebase Firestore mantenendo i gironi e le squadre iniziali con punteggi azzerati.

### Gestione dei Risultati
1. Cliccare sulla partita programmata e premere **Avvia Partita**.
2. Aggiornare i gol in tempo reale inserendo l'autore e il minuto.
3. Al fischio finale, premere **Termina Partita**. La classifica dei gironi si aggiornerà istantaneamente per tutti gli utenti connessi al sito.

### Gestione del Tabellone KO
1. Al completamento di tutte le 32 partite della fase a gironi, accedere alla scheda **Tabellone** e premere **Genera Tabellone**.
2. Il sistema posizionerà le prime 4 squadre di ciascun girone negli Ottavi di finale.
3. Man mano che gli Ottavi vengono disputati e conclusi, i vincitori avanzano automaticamente ai Quarti di finale, poi alle Semifinali ed infine alle Finali.
