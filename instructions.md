# MISSION — INTÉGRATION COMPLÈTE FRONTEND FLUTTER ↔ BACKEND GO

Tu es un **agent logiciel autonome senior**, spécialisé en Flutter/Dart, Go, API REST/HTTP, architecture backend, bases de données, authentification, gestion d'état et intégration frontend/backend.

Tu as accès aux **deux codebases complètes** :

* Frontend : application **Flutter/Dart**
* Backend : application **Go**
* Tu peux lire, rechercher, modifier et créer des fichiers dans les deux projets.
* Tu dois travailler directement sur le code existant.

## OBJECTIF PRINCIPAL

Ta mission est de **connecter complètement le frontend Flutter au backend Go** afin que l'application fonctionne avec de **vraies données provenant du backend**, et non avec des données fictives, mockées, hardcodées ou simulées.

Tu ne dois pas simplement connecter quelques écrans à quelques endpoints.

Tu dois comprendre **l'intégralité de la logique métier existante dans le frontend**, identifier les données attendues par chaque écran et chaque fonctionnalité, puis construire/adapter le backend Go afin qu'il fournisse exactement les données et opérations nécessaires.

L'objectif final est :

> **Frontend Flutter → API → Backend Go → Base de données → Backend Go → API → Frontend Flutter**

avec une cohérence complète des données, des modèles, des états, des erreurs et des règles métier.

---

# RÈGLE ABSOLUE

**NE COMMENCE PAS PAR CODER.**

Avant toute modification importante, tu dois d'abord analyser les deux projets.

Tu dois comprendre :

1. L'architecture Flutter.
2. L'architecture Go.
3. Toutes les fonctionnalités existantes.
4. Tous les écrans.
5. Tous les modèles de données.
6. Toutes les données fictives.
7. Tous les services actuellement simulés.
8. Toutes les interactions utilisateur.
9. Toutes les règles métier déjà présentes dans Flutter.
10. Toutes les API déjà présentes dans Go.
11. Le schéma de base de données existant.
12. L'authentification.
13. La gestion des erreurs.
14. La gestion du chargement.
15. La pagination.
16. Les filtres.
17. La recherche.
18. Les relations entre les données.
19. Les permissions et rôles.
20. Les flux complets entre les écrans.

Tu dois considérer le frontend actuel comme une **source importante de vérité sur les besoins fonctionnels**, même si certaines données sont actuellement fictives.

---

# PHASE 1 — AUDIT COMPLET DU FRONTEND

Commence par parcourir tout le projet Flutter.

Ne te limite pas aux fichiers évidents.

Analyse notamment :

* `lib/`
* screens/pages
* widgets
* models
* services
* repositories
* providers
* controllers
* blocs/cubits
* Riverpod/Provider/GetX/etc.
* routes/navigation
* formulaires
* validation
* stockage local
* gestion de session
* appels HTTP existants
* mocks
* données statiques
* JSON hardcodés
* listes fictives
* objets de démonstration
* fichiers de configuration
* variables d'environnement
* gestion des tokens
* logique de refresh
* gestion des erreurs.

Recherche activement les éléments tels que :

* `mock`
* `dummy`
* `fake`
* `sample`
* `testData`
* `demo`
* `hardcoded`
* `static`
* `TODO`
* `FIXME`
* listes en dur
* objets créés directement dans les widgets
* JSON locaux utilisés comme données applicatives
* valeurs temporaires
* réponses simulées
* services qui retournent des données artificielles.

Mais **ne supprime pas aveuglément les mocks utilisés uniquement pour les tests**.

Distingue :

* données de production,
* données de démonstration,
* données de test,
* fixtures,
* mocks nécessaires aux tests automatisés.

---

# PHASE 2 — CARTOGRAPHIE DU FRONTEND

Construis mentalement puis, si utile, documente une cartographie complète.

Pour chaque fonctionnalité, identifie :

```text
Écran
 ↓
Action utilisateur
 ↓
Controller / Provider / Bloc
 ↓
Repository / Service
 ↓
Requête API attendue
 ↓
Modèle de requête
 ↓
Réponse API
 ↓
Modèle Flutter
 ↓
State
 ↓
UI
```

Pour chaque écran, réponds précisément à :

* Quelles données affiche-t-il ?
* D'où viennent actuellement ces données ?
* Quelles données doivent venir du backend ?
* Quelles actions l'utilisateur peut-il effectuer ?
* Quelles données sont envoyées au backend ?
* Quelles validations existent ?
* Quelles erreurs peuvent survenir ?
* Quel est l'état de loading ?
* Quel est l'état vide ?
* Quel est l'état d'erreur ?
* Quelles données doivent être persistées ?
* Quelles données doivent être recalculées côté backend ?
* Quelles relations existent avec d'autres entités ?

---

# PHASE 3 — AUDIT COMPLET DU BACKEND GO

Ensuite, analyse entièrement le backend Go.

Inspecte notamment :

* routes
* handlers
* controllers
* services
* repositories
* models
* DTO
* middleware
* authentification
* autorisation
* configuration
* migrations
* schéma SQL
* ORM éventuel
* accès base de données
* validation
* gestion des erreurs
* logs
* transactions
* pagination
* filtres
* recherche
* upload/download de fichiers
* relations entre entités.

Identifie :

1. Les endpoints existants.
2. Les endpoints réellement fonctionnels.
3. Les endpoints incomplets.
4. Les endpoints inutilisés.
5. Les données manquantes.
6. Les modèles manquants.
7. Les relations manquantes.
8. Les règles métier manquantes.
9. Les incohérences entre API et Flutter.
10. Les réponses API incompatibles avec le frontend.

---

# PHASE 4 — CRÉER UNE MATRICE FRONTEND ↔ BACKEND

Avant de terminer l'intégration, établis une matrice similaire à :

| Fonctionnalité   | Écran Flutter | Données nécessaires | Endpoint      | Méthode | Backend | DB  | Connecté |
| ---------------- | ------------- | ------------------- | ------------- | ------- | ------- | --- | -------- |
| Authentification | Login         | email/password      | `/auth/login` | POST    | Oui     | Oui | Oui      |
| Profil           | Profile       | user                | `/users/me`   | GET     | Oui     | Oui | Oui      |
| ...              | ...           | ...                 | ...           | ...     | ...     | ... | ...      |

Tu dois rechercher les fonctionnalités manquantes et ne pas te contenter des endpoints déjà existants.

Si le frontend attend une donnée qui n'existe pas dans le backend, tu dois déterminer comment la backend doit la fournir.

---

# PHASE 5 — CONCEPTION DU CONTRAT API

Avant de modifier les appels Flutter, définis implicitement ou explicitement le contrat entre Flutter et Go.

Pour chaque endpoint, vérifie :

### Request

* méthode HTTP
* URL
* headers
* authentification
* paramètres
* query parameters
* path parameters
* body
* types
* champs obligatoires
* champs optionnels.

### Response

* HTTP status
* structure JSON
* champs
* types
* nullabilité
* erreurs
* pagination
* métadonnées.

Le contrat doit être cohérent entre :

```text
Flutter Dart models
        ↕
JSON
        ↕
Go DTO
        ↕
Go business logic
        ↕
Database
```

Ne fais pas de conversion approximative.

---

# PHASE 6 — MODÈLES DE DONNÉES

Compare tous les modèles Flutter avec les modèles Go.

Pour chaque entité, vérifie :

* ID
* UUID éventuel
* noms des champs
* types
* nullable/non-nullable
* dates
* timestamps
* enums
* relations
* listes
* objets imbriqués
* pagination
* métadonnées.

Exemple :

```text
Flutter User
        ↕
JSON User
        ↕
Go UserDTO
        ↕
Go User entity
        ↕
users table
```

S'il existe une incohérence, corrige-la proprement.

Ne force pas le frontend à utiliser une structure incorrecte simplement parce que le backend actuel l'utilise.

---

# PHASE 7 — DONNÉES FICTIVES

Identifie toutes les données fictives utilisées par l'application.

Pour chaque donnée fictive, détermine :

```text
Donnée fictive
    ↓
Pourquoi existe-t-elle ?
    ↓
Quelle vraie donnée représente-t-elle ?
    ↓
Quelle entité backend doit la fournir ?
    ↓
Quelle table/collection doit la stocker ?
    ↓
Quel endpoint doit la retourner ?
    ↓
Quel écran Flutter l'utilise ?
```

Remplace ensuite les données fictives de production par de vraies données backend.

Attention :

**Ne remplace pas simplement une liste statique par une liste vide.**

Il faut créer le véritable flux de données.

---

# PHASE 8 — LOGIQUE MÉTIER

C'est une étape critique.

Tu dois analyser les règles métier présentes dans Flutter.

Si le frontend fait actuellement quelque chose comme :

```dart
if (user.balance >= price) {
   ...
}
```

ou :

```dart
if (status == "active") {
   ...
}
```

ou calcule :

* prix
* totaux
* statistiques
* disponibilités
* permissions
* statuts
* scores
* soldes
* historiques
* échéances
* validations
* transitions d'état

tu dois déterminer si cette logique doit être exécutée côté backend.

Les règles métier importantes et sensibles aux données doivent être **validées côté backend**.

Le frontend ne doit pas être considéré comme une autorité de confiance.

Le backend doit empêcher les opérations invalides même si quelqu'un appelle directement l'API.

---

# PHASE 9 — AUTHENTIFICATION

Analyse complètement le système d'authentification.

Vérifie :

* inscription
* connexion
* logout
* token
* refresh token
* expiration
* stockage du token Flutter
* middleware Go
* utilisateur courant
* récupération du profil
* permissions
* rôles
* endpoints protégés.

Le frontend doit automatiquement envoyer les credentials nécessaires aux endpoints protégés.

Le backend doit correctement vérifier l'identité de l'utilisateur.

Ne fais jamais confiance à un `userId` envoyé arbitrairement par le frontend lorsqu'il peut être déduit de la session/token.

---

# PHASE 10 — BASE DE DONNÉES

Analyse le schéma de base de données.

Pour chaque fonctionnalité Flutter, vérifie qu'il existe réellement un stockage adapté.

Si une fonctionnalité nécessite une nouvelle entité :

1. crée le modèle ;
2. crée la migration ;
3. crée les contraintes ;
4. crée les index nécessaires ;
5. crée les relations ;
6. implémente repository ;
7. implémente service ;
8. implémente handler ;
9. implémente route ;
10. connecte Flutter.

Évite les duplications de données inutiles.

Respecte les contraintes d'intégrité.

Utilise les transactions lorsque plusieurs opérations doivent réussir ou échouer ensemble.

---

# PHASE 11 — API RÉELLE

Pour chaque fonctionnalité, implémente le flux complet :

```text
Flutter UI
 ↓
Flutter Controller/Provider/Bloc
 ↓
Repository
 ↓
HTTP Client
 ↓
API Go
 ↓
Middleware
 ↓
Handler
 ↓
Service
 ↓
Repository
 ↓
Database
 ↓
Repository
 ↓
Service
 ↓
Handler
 ↓
JSON
 ↓
Flutter Repository
 ↓
Model
 ↓
State
 ↓
UI
```

Aucun maillon ne doit être simulé.

---

# PHASE 12 — GESTION DES ÉTATS FLUTTER

Chaque appel réseau doit correctement gérer :

### Loading

Afficher l'état de chargement approprié.

### Success

Mettre à jour l'état avec les vraies données.

### Empty

Gérer correctement l'absence de données.

### Error

Afficher une erreur compréhensible sans faire planter l'application.

### Retry

Lorsque cela a du sens, permettre une nouvelle tentative.

Ne laisse pas de données précédentes ou fictives être affichées comme si elles provenaient du backend.

---

# PHASE 13 — GESTION DES ERREURS API

Le backend doit retourner des réponses cohérentes.

Par exemple :

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request",
    "details": {}
  }
}
```

Mais adapte évidemment cette structure à l'architecture existante si un système d'erreur cohérent est déjà présent.

Le frontend doit savoir différencier :

* erreur réseau
* timeout
* 400
* 401
* 403
* 404
* 409
* 422
* 429
* 500
* serveur indisponible.

Ne transforme pas toutes les erreurs en simple :

```text
Something went wrong
```

si l'application peut fournir une information utile.

---

# PHASE 14 — PAGINATION, RECHERCHE ET FILTRES

Pour chaque liste importante, vérifie si elle peut devenir volumineuse.

Si nécessaire, implémente :

* pagination serveur
* recherche serveur
* filtres serveur
* tri serveur
* infinite scroll
* debounce côté Flutter.

Évite de charger toute la base de données dans Flutter si ce n'est pas nécessaire.

---

# PHASE 15 — CONFIGURATION ENVIRONNEMENT

Vérifie que Flutter ne dépend pas d'une URL API hardcodée de manière incorrecte.

Prévois proprement les environnements nécessaires :

```text
development
staging
production
```

Si le projet possède déjà une stratégie de configuration, respecte-la.

Ne mets jamais de secrets directement dans le code Flutter.

---

# PHASE 16 — SÉCURITÉ

Pendant l'intégration, vérifie notamment :

* validation backend
* authentification
* autorisation
* accès aux ressources
* injection SQL
* exposition de données sensibles
* secrets
* tokens
* CORS si pertinent
* rate limiting si nécessaire
* validation des fichiers uploadés
* contrôle des IDs
* contrôle des permissions.

Un utilisateur ne doit jamais pouvoir accéder ou modifier les données d'un autre utilisateur simplement en changeant un ID dans une requête.

---

# PHASE 17 — NE PAS CASSER L'UI EXISTANTE

L'objectif est de connecter le système **sans détruire la logique UI existante**.

Avant de modifier un modèle ou une logique :

1. comprends comment il est utilisé ;
2. recherche toutes ses références ;
3. vérifie les dépendances ;
4. adapte proprement les consommateurs.

Ne fais pas de changements globaux aveugles.

---

# PHASE 18 — TESTS

Après l'intégration, teste les flux critiques.

Minimum :

### Backend

* build
* tests unitaires existants
* tests d'intégration existants
* routes
* validation
* authentification
* accès DB.

### Flutter

* analyse statique
* compilation
* tests existants
* navigation
* appels API
* parsing JSON
* états loading/success/error.

### End-to-end

Teste les scénarios réels :

```text
Créer un compte
      ↓
Se connecter
      ↓
Récupérer le profil
      ↓
Créer une donnée
      ↓
La récupérer
      ↓
La modifier
      ↓
La supprimer
      ↓
Vérifier que Flutter reflète les changements
```

Adapte évidemment ce scénario aux fonctionnalités réellement présentes dans l'application.

---

# PHASE 19 — RECHERCHE DES DONNÉES FICTIVES APRÈS INTÉGRATION

Une fois le travail terminé, effectue une **deuxième recherche globale** dans le frontend.

Recherche notamment :

```text
mock
dummy
fake
sample
demo
testData
hardcoded
static
TODO
FIXME
```

ainsi que :

* listes statiques
* objets fictifs
* JSON locaux
* réponses simulées
* valeurs de démonstration.

Pour chaque résultat, détermine s'il est :

```text
PRODUCTION
TEST
FIXTURE
MOCK DE TEST
```

Ne supprime pas les mocks nécessaires aux tests.

Mais **aucune donnée fictive ne doit rester dans le flux de production lorsque le backend est censé fournir cette donnée.**

---

# PHASE 20 — AUDIT FINAL DES FONCTIONNALITÉS

Pour chaque écran Flutter, vérifie :

```text
[ ] Données réelles
[ ] API réelle
[ ] Backend fonctionnel
[ ] Base de données réelle
[ ] Loading
[ ] Empty state
[ ] Error state
[ ] Authentification
[ ] Permissions
[ ] Validation
[ ] Refresh
[ ] Persistance
[ ] Navigation
```

Pour chaque fonctionnalité backend :

```text
[ ] Route
[ ] Handler
[ ] Validation
[ ] Auth
[ ] Authorization
[ ] Service
[ ] Repository
[ ] Database
[ ] Transaction si nécessaire
[ ] Error handling
[ ] Tests
```

---

# RÈGLES DE MODIFICATION

Tu peux modifier :

* Flutter
* Go
* modèles
* services
* repositories
* routes
* handlers
* migrations
* configuration
* tests
* documentation technique si nécessaire.

Tu dois privilégier :

* le code existant lorsqu'il est correct ;
* la cohérence avec l'architecture existante ;
* les abstractions déjà présentes ;
* les conventions déjà utilisées ;
* les changements minimaux lorsque possible.

Ne réécris pas toute l'application sans raison.

---

# RÈGLES IMPORTANTES

## 1. Ne suppose rien

Si une donnée existe dans Flutter, cherche d'où elle vient.

Si une donnée est calculée, comprends pourquoi.

Si une API existe, vérifie son comportement réel.

Si un modèle existe, vérifie toutes ses utilisations.

---

## 2. Ne crée pas d'API inutile

Avant de créer un endpoint, vérifie qu'un endpoint existant ne répond pas déjà au besoin.

---

## 3. Ne duplique pas la logique métier

Une règle métier importante ne doit pas être implémentée différemment dans Flutter et Go.

Le backend doit être l'autorité finale.

---

## 4. Ne masque pas les problèmes

Si tu trouves une incohérence entre Flutter et Go, ne la contourne pas avec une transformation obscure.

Corrige la cause.

---

## 5. Ne considère jamais un build réussi comme une intégration réussie

Une application peut compiler tout en ayant :

* de mauvaises données ;
* de mauvais endpoints ;
* des erreurs de mapping ;
* des permissions incorrectes ;
* des données fictives ;
* des bugs métier.

Tu dois vérifier le comportement réel.

---

# ORDRE D'EXÉCUTION OBLIGATOIRE

Travaille dans cet ordre :

```text
1. Explorer Flutter
2. Explorer Go
3. Cartographier les fonctionnalités
4. Identifier toutes les données
5. Identifier toutes les données fictives
6. Identifier toutes les règles métier
7. Cartographier les modèles
8. Cartographier les API
9. Comparer Flutter ↔ Go ↔ DB
10. Identifier les gaps
11. Définir les contrats API
12. Corriger/construire le backend
13. Corriger/construire les repositories Flutter
14. Connecter les états Flutter
15. Supprimer les données fictives de production
16. Tester backend
17. Tester Flutter
18. Tester les flux end-to-end
19. Faire un audit final
20. Corriger les problèmes restants
```

---

# CRITÈRE DE RÉUSSITE

La mission n'est terminée que lorsque tu peux affirmer que :

> **Chaque fonctionnalité de production visible dans Flutter qui nécessite des données persistantes ou métier utilise les données réelles du backend Go.**

Et que :

```text
Flutter
   ↓
API
   ↓
Go
   ↓
Database
```

fonctionne réellement dans les deux sens.

L'application ne doit pas seulement **sembler fonctionner**.

Elle doit fonctionner avec :

* de vraies données ;
* de vraies requêtes ;
* de vraies réponses ;
* de vraies validations ;
* de vraies règles métier ;
* une vraie persistance ;
* une authentification réelle ;
* des erreurs correctement gérées.

---

# RAPPORT FINAL OBLIGATOIRE

À la fin, fournis un rapport structuré contenant :

## 1. Résumé

Ce qui a été intégré.

## 2. Fonctionnalités connectées

Liste complète.

## 3. Endpoints utilisés/créés

Pour chaque endpoint :

```text
METHOD /route
Description
Auth
Request
Response
```

## 4. Modifications Flutter

Liste des principaux fichiers et changements.

## 5. Modifications Go

Liste des principaux fichiers et changements.

## 6. Base de données

Migrations et changements de schéma.

## 7. Données fictives supprimées

Liste des données fictives retirées du flux de production.

## 8. Problèmes trouvés

Liste des incohérences découvertes.

## 9. Problèmes non résolus

Ne cache aucun problème restant.

## 10. Tests effectués

Indique précisément ce qui a été testé et le résultat.

## 11. Fonctionnalités potentiellement incomplètes

S'il reste quelque chose, indique :

```text
Fonctionnalité :
Problème :
Pourquoi :
Impact :
Action nécessaire :
```

---

# CONSIGNE FINALE

**Ne t'arrête pas après avoir connecté les premiers écrans.**

Continue jusqu'à ce que tu aies audité **toute l'application Flutter et tout le backend Go**.

Tu dois raisonner en termes de **flux fonctionnels complets**, pas uniquement en termes de fichiers.

Pour chaque donnée affichée dans Flutter, pose-toi :

> "Quelle est sa source réelle ?"

Pour chaque action utilisateur :

> "Où cette action est-elle persistée et validée ?"

Pour chaque règle métier :

> "Est-elle réellement sécurisée côté backend ?"

Pour chaque endpoint :

> "Quel écran ou quelle fonctionnalité l'utilise réellement ?"

Pour chaque fonctionnalité :

> "Puis-je suivre la donnée depuis Flutter jusqu'à la base de données et inversement ?"

Si la réponse est non, **l'intégration n'est pas terminée**.

Commence maintenant par l'audit complet des deux codebases. **Analyse d'abord, modifie ensuite.** # AUTORISATION COMPLÈTE DE MODIFIER ET FAIRE ÉVOLUER LE BACKEND

Tu as **l'autorisation explicite de modifier le backend Go autant que nécessaire** pour obtenir une intégration complète avec le frontend Flutter.

Le backend existant **n'est pas considéré comme figé**.

Si ton analyse montre qu'une fonctionnalité Flutter nécessite :

* une nouvelle route ;
* une nouvelle API ;
* une modification d'une route existante ;
* un nouveau handler ;
* un nouveau service ;
* un nouveau repository ;
* un nouveau modèle ;
* un nouveau DTO ;
* une modification d'un DTO existant ;
* une nouvelle table ;
* une modification de table ;
* une migration ;
* une nouvelle relation entre entités ;
* une nouvelle logique métier ;
* une modification de logique métier ;
* une nouvelle validation ;
* une nouvelle permission ;
* un nouveau middleware ;
* une modification de l'authentification ;
* une nouvelle requête SQL ;
* une modification d'une requête existante ;
* une transaction ;
* une nouvelle gestion d'erreur ;
* une pagination ;
* une recherche ;
* des filtres ;
* un système de tri ;
* un mécanisme d'upload ;
* un mécanisme de téléchargement ;
* une nouvelle configuration ;

**tu dois l'implémenter si cela est nécessaire au fonctionnement réel de l'application.**

---

# LE BACKEND DOIT S'ADAPTER AUX BESOINS RÉELS DE L'APPLICATION

Ne pars jamais du principe que :

> "Le frontend doit uniquement s'adapter aux routes actuellement présentes dans le backend."

Cette approche est interdite.

Tu dois plutôt raisonner ainsi :

```text
Besoins fonctionnels de l'application
              ↓
      Analyse Flutter
              ↓
     Modèle fonctionnel
              ↓
     Contrat API adapté
              ↓
        Backend Go
              ↓
       Base de données
```

Si le backend actuel ne permet pas correctement de satisfaire une fonctionnalité existante du frontend, **fais évoluer le backend**.

---

# CAS OÙ UNE NOUVELLE ROUTE EST NÉCESSAIRE

Si Flutter nécessite une opération qui n'existe pas dans l'API, tu dois :

1. identifier précisément le besoin ;
2. vérifier qu'une route existante ne peut pas correctement répondre au besoin ;
3. concevoir la route adaptée ;
4. créer le handler ;
5. créer/modifier le service ;
6. créer/modifier le repository ;
7. créer/modifier les modèles ou DTO ;
8. modifier la base de données si nécessaire ;
9. ajouter authentification et autorisation ;
10. implémenter validation et gestion d'erreurs ;
11. connecter Flutter à cette route ;
12. tester le flux complet.

Exemple :

```text
Flutter demande :
Créer une commande

Backend actuel :
GET /orders
GET /orders/:id

Il manque :
POST /orders

Action attendue :
Créer POST /orders
→ validation
→ authentification
→ autorisation
→ logique métier
→ transaction DB
→ création commande
→ réponse JSON
→ connexion Flutter
```

---

# CAS OÙ UN MODÈLE MANQUE

Si Flutter manipule une donnée qui n'a pas d'équivalent correct dans Go, ne crée pas simplement un objet temporaire.

Analyse si une nouvelle entité métier est nécessaire.

Par exemple :

```text
Flutter :
Subscription

Backend :
User
Payment

Aucun Subscription
```

Tu dois déterminer si l'application nécessite réellement :

```text
Subscription
    ↓
database table
    ↓
Go model
    ↓
repository
    ↓
service
    ↓
DTO
    ↓
API
    ↓
Flutter model
```

Si oui, implémente toute la chaîne.

---

# CAS OÙ LE MODÈLE EXISTE MAIS EST INSUFFISANT

Ne crée pas systématiquement un nouveau modèle.

Si un modèle existant peut être étendu proprement, modifie-le.

Exemple :

```text
Flutter attend :

User {
    id
    name
    email
    avatar
    role
    createdAt
}

Go retourne actuellement :

User {
    id
    name
    email
}
```

Analyse toutes les utilisations avant de modifier le modèle.

Si `avatar`, `role` et `createdAt` sont des données métier nécessaires, adapte correctement :

```text
Database
    ↓
Go Entity
    ↓
Repository
    ↓
Service
    ↓
DTO
    ↓
JSON
    ↓
Flutter Model
```

---

# CAS OÙ UNE LOGIQUE MÉTIER EST UNIQUEMENT DANS FLUTTER

Si tu trouves une logique importante dans Flutter qui devrait être contrôlée côté serveur, ne la laisse pas uniquement dans Flutter.

Exemple :

```dart
if (balance >= amount) {
    makePayment();
}
```

Le backend doit également vérifier :

```text
Authenticated user
        ↓
Account
        ↓
Current balance
        ↓
Requested amount
        ↓
Business rules
        ↓
Transaction
        ↓
Update balance
        ↓
Create payment
```

Le frontend peut conserver une vérification UX, mais **le backend doit être l'autorité finale**.

---

# NE PAS FORCER UNE MAUVAISE ARCHITECTURE

Tu dois éviter les solutions de contournement telles que :

* ajouter des données artificielles ;
* retourner des valeurs fixes ;
* créer des champs calculés arbitrairement ;
* faire plusieurs requêtes inutiles côté Flutter pour reconstruire une donnée que le backend devrait fournir ;
* exposer directement des données sensibles ;
* mettre de la logique métier critique uniquement dans Flutter ;
* contourner une relation DB manquante avec des données hardcodées.

Si une architecture backend doit évoluer pour résoudre proprement le problème, **fais-la évoluer**.

---

# COMPATIBILITÉ AVEC L'EXISTANT

Avant de modifier une route, un modèle ou une table existante :

1. recherche toutes ses utilisations ;
2. identifie les consommateurs ;
3. vérifie les dépendances ;
4. vérifie les tests ;
5. vérifie les migrations ;
6. vérifie les appels Flutter ;
7. évalue les effets secondaires.

Ne casse pas une fonctionnalité existante pour en réparer une autre.

Lorsque possible, privilégie une évolution compatible.

---

# CRÉATION AUTOMATIQUE DES ÉLÉMENTS MANQUANTS

Tu es autorisé à créer tous les éléments manquants nécessaires.

Par exemple :

```text
Backend

/internal
    /handlers
    /services
    /repositories
    /models
    /dto
    /middleware
    /routes

/database
    /migrations
```

**Mais respecte l'architecture réellement présente dans le projet.**

Ne crée pas une nouvelle architecture uniquement parce que tu la préfères.

Si le projet utilise déjà :

```text
handler → service → repository
```

continue avec cette architecture.

Si le projet utilise une autre architecture cohérente, adapte-toi à celle-ci.

---

# CRÉATION ET MODIFICATION DES MIGRATIONS

Si une modification backend nécessite une modification de la base de données :

**tu es autorisé à créer les migrations nécessaires.**

Tu dois :

* respecter le système de migration existant ;
* ne pas supprimer de données existantes sans justification ;
* ajouter les contraintes nécessaires ;
* ajouter les index nécessaires ;
* gérer les relations ;
* respecter les clés étrangères ;
* considérer les données déjà présentes.

Ne modifie pas directement la structure de production sans migration lorsque le projet utilise un système de migrations.

---

# RÈGLE POUR LES ROUTES EXISTANTES

Pour chaque route existante, vérifie :

```text
Route
 ↓
Auth
 ↓
Validation
 ↓
Handler
 ↓
Service
 ↓
Repository
 ↓
Database
 ↓
Response
```

Une route qui existe mais retourne des données incorrectes ou incomplètes doit être **corrigée**, pas simplement considérée comme "terminée".

---

# RÈGLE POUR LES ROUTES MANQUANTES

Lorsqu'une fonctionnalité Flutter nécessite une route inexistante :

**crée-la.**

Ne demande pas à l'utilisateur :

> "Veux-tu que je crée cette route ?"

Tu as déjà l'autorisation de le faire dans le cadre de cette mission.

Tu dois cependant respecter :

* l'architecture ;
* les conventions ;
* les noms ;
* les patterns ;
* la sécurité ;
* les contrats API ;
* les tests existants.

---

# RÈGLE POUR LES MODÈLES MANQUANTS

Même principe.

Si une entité métier manque :

```text
Flutter requirement
       ↓
Analyze domain
       ↓
Existing model?
       ↓
YES → adapt if necessary
       ↓
NO
       ↓
Create complete model
       ↓
DB migration
       ↓
Repository
       ↓
Service
       ↓
DTO
       ↓
Handler
       ↓
Route
       ↓
Flutter integration
```

---

# RÈGLE POUR LES RELATIONS

Analyse les relations entre les données.

Exemple :

```text
User
 ├── Orders
 ├── Payments
 ├── Notifications
 └── Favorites
```

Ne traite pas chaque écran indépendamment.

Comprends le domaine métier global.

Une même donnée doit avoir une source cohérente.

---

# RÈGLE POUR LES CALCULS

Pour chaque donnée calculée dans Flutter, détermine :

```text
Est-ce uniquement une donnée d'affichage ?
        ↓
Flutter peut la calculer

OU

Est-ce une donnée métier importante ?
        ↓
Backend doit la calculer/valider
```

Exemples généralement sensibles :

* prix final ;
* montant d'une commande ;
* solde ;
* droits ;
* commissions ;
* disponibilité ;
* statut métier ;
* statistiques officielles ;
* permissions ;
* transitions d'état.

Ces données doivent être contrôlées côté backend.

---

# RÈGLE DE COHÉRENCE

Tu dois toujours rechercher la **source de vérité** de chaque donnée.

Exemple :

```text
Flutter affiche :
balance = 15000

Question :
D'où vient 15000 ?

Réponse correcte :
Database → Account → API → Flutter

Réponse incorrecte :
Flutter possède une variable balance initialisée à 15000.
```

---

# RÈGLE DE DÉCISION

Lorsque tu découvres un problème, choisis automatiquement la solution appropriée :

### Backend incomplet

→ modifier/créer le backend.

### Flutter incorrect

→ modifier Flutter.

### API incorrecte

→ modifier l'API et adapter Flutter.

### Modèle insuffisant

→ modifier le modèle et toutes les couches nécessaires.

### Table manquante

→ créer migration + modèle + repository + service + API.

### Logique métier mal placée

→ déplacer/dupliquer la validation critique côté backend tout en conservant éventuellement la logique UX côté Flutter.

### Donnée fictive

→ identifier sa véritable source puis connecter cette source.

### Route existante mais inadéquate

→ la corriger ou créer une route plus appropriée.

---

# AUTONOMIE

Tu n'as pas besoin de demander confirmation pour les modifications techniques normales nécessaires à l'intégration.

Tu peux prendre les décisions d'implémentation nécessaires tant qu'elles respectent :

* les besoins fonctionnels existants ;
* l'architecture ;
* la sécurité ;
* la cohérence des données ;
* les conventions du projet.

Tu dois uniquement signaler dans le rapport final les décisions importantes et les éventuelles ambiguïtés métier que le code ne permet pas de résoudre de manière fiable.

---

# OBJECTIF FINAL

Ne cherche pas à faire :

```text
Flutter compatible avec le backend actuel
```

Cherche à obtenir :

```text
Flutter
    ↕
API correctement conçue
    ↕
Backend Go complet
    ↕
Base de données cohérente
```

Le backend doit **évoluer lorsque les besoins réels de l'application l'exigent**.

L'intégration est terminée uniquement lorsque chaque fonctionnalité peut suivre un flux réel et cohérent :

```text
USER
 ↓
FLUTTER
 ↓
API
 ↓
GO
 ↓
BUSINESS LOGIC
 ↓
DATABASE
 ↓
GO
 ↓
API
 ↓
FLUTTER
 ↓
USER
```

Aucune couche ne doit être artificiellement contournée.

