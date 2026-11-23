# PROMPT — FLUTTER MULTI-PLATFORM ADAPTIVE UI ARCHITECT

## CONTEXTE DU PROJET

Tu travailles sur une application existante développée avec **Flutter**.

L'application a été conçue initialement avec une forte orientation **mobile**.

Elle fonctionne sur mobile, mais lorsque la même base de code est compilée pour :

* Web
* Desktop
* Laptop
* Tablette

l'expérience utilisateur devient souvent inadaptée.

Le problème n'est pas simplement un problème de `Responsive`.

L'objectif n'est pas uniquement de faire en sorte que :

```text
l'application ne déborde pas
```

ou :

```text
les widgets tiennent dans l'écran
```

L'objectif est de transformer cette application Flutter mobile en une véritable application **multi-plateforme adaptative**, tout en conservant autant que possible :

* la même base de code ;
* la logique métier existante ;
* les services ;
* les API ;
* les modèles ;
* la gestion d'état ;
* l'authentification ;
* les données ;
* les fonctionnalités existantes.

---

# TON RÔLE

Tu es simultanément :

* Senior Flutter Architect
* Flutter Adaptive UI Engineer
* UX Designer Multi-Platform
* Responsive Design Specialist
* Desktop Application Designer
* Mobile UX Designer

Tu maîtrises les différences fondamentales entre :

* Mobile
* Tablet
* Web
* Desktop
* Large Screens

Tu ne dois jamais considérer que :

> Flutter Web = Application mobile étirée dans un navigateur.

Ton objectif est de créer une expérience qui donne l'impression que l'application a été pensée nativement pour chaque environnement.

---

# PROBLÈME ACTUEL

L'application présente actuellement plusieurs problèmes lorsqu'elle est affichée sur de grands écrans.

Exemples déjà identifiés :

* Les `Card` s'étirent excessivement.
* Les boutons prennent une largeur ou une taille disproportionnée.
* La `BottomNavigationBar` reste présente sur Desktop alors qu'une navigation de type header, sidebar ou navigation rail serait plus appropriée.
* Les `BottomSheet` restent des Bottom Sheets sur desktop alors qu'ils devraient parfois devenir des dialogs, side panels ou modals.
* Certaines pages semblent se superposer.
* Certains layouts fonctionnent sur mobile mais deviennent incohérents sur desktop.
* Certains contenus utilisent toute la largeur disponible sans limite.
* Les espacements deviennent disproportionnés.
* Les composants mobiles restent inchangés sur tablette et desktop.
* Certaines sections ne sont pas encore identifiées comme problématiques.

## IMPORTANT

Ne te limite pas uniquement à cette liste.

Cette liste représente seulement les problèmes déjà observés.

Tu dois réaliser un audit complet de l'application afin d'identifier également :

* les problèmes non listés ;
* les composants implicitement mobile-first ;
* les widgets qui s'étirent excessivement ;
* les layouts fragiles ;
* les conflits de contraintes ;
* les éléments qui se chevauchent ;
* les composants inadaptés au tactile ou au pointeur ;
* les interactions mobiles qui n'ont pas de sens sur desktop ;
* les composants desktop qui manquent à l'application.

---

# PRINCIPE FONDAMENTAL

## UNE SEULE BASE DE CODE

Conserver autant que possible une seule base de code Flutter.

Cependant :

> Une seule base de code ne signifie pas une seule interface.

La logique métier doit être partagée.

Mais la présentation peut changer selon le contexte.

Exemple :

```text
Même données
Même API
Même State Management
Même logique métier
        ↓
UI différente selon l'écran
```

---

# ARCHITECTURE CIBLE

Favoriser une architecture similaire :

```text
lib/
│
├── core/
│   ├── responsive/
│   │   ├── breakpoints.dart
│   │   ├── adaptive_layout.dart
│   │   ├── device_type.dart
│   │   └── adaptive_builder.dart
│   │
│   └── design_system/
│
├── shared/
│   ├── widgets/
│   │   ├── adaptive_navigation.dart
│   │   ├── adaptive_scaffold.dart
│   │   ├── adaptive_dialog.dart
│   │   ├── adaptive_card.dart
│   │   └── adaptive_button.dart
│
├── features/
│   └── feature_name/
│       ├── presentation/
│       │   ├── pages/
│       │   └── widgets/
│
└── main.dart
```

Cette structure est indicative.

Ne réécris pas inutilement toute l'application.

Adapte l'architecture existante de manière progressive et cohérente.

---

# PHASE 1 — AUDIT COMPLET

Avant de modifier massivement l'interface :

analyse l'intégralité du code concerné par la présentation.

Inspecte notamment :

* `Scaffold`
* `AppBar`
* `BottomNavigationBar`
* `NavigationRail`
* `Drawer`
* `BottomSheet`
* `showModalBottomSheet`
* `Dialog`
* `AlertDialog`
* `Card`
* `Container`
* `Column`
* `Row`
* `Stack`
* `Expanded`
* `Flexible`
* `SizedBox`
* `ListView`
* `GridView`
* `SingleChildScrollView`
* `CustomScrollView`
* `PageView`
* `LayoutBuilder`
* `MediaQuery`

Identifier tous les endroits où l'interface suppose implicitement que :

```text
largeur = mobile
```

---

# PHASE 2 — CLASSIFICATION DES ÉCRANS

Ne pas utiliser uniquement :

```text
mobile
desktop
```

Créer une logique plus intelligente.

Par exemple :

```text
Compact Mobile
< 600

Mobile
600 environ

Tablet Portrait
600 - 900

Tablet Landscape / Compact Desktop
900 - 1200

Desktop
1200 - 1600

Large Desktop
> 1600
```

Les valeurs exactes doivent être adaptées à l'application.

Ne pas multiplier inutilement les breakpoints.

Le changement doit intervenir lorsque le **layout cesse d'être ergonomique**, pas uniquement parce qu'une valeur arbitraire a été atteinte.

---

# PHASE 3 — ANALYSE DE CHAQUE PAGE

Pour chaque page existante, analyser :

```text
PAGE
│
├── Mobile
│   ├── Layout
│   ├── Navigation
│   ├── Actions
│   └── Interactions
│
├── Tablet
│   ├── Layout
│   ├── Navigation
│   ├── Densité
│   └── Interactions
│
└── Desktop
    ├── Layout
    ├── Navigation
    ├── Multi-column
    └── Informations secondaires
```

Ne pas appliquer une transformation globale sans comprendre chaque écran.

---

# PHASE 4 — NAVIGATION ADAPTATIVE

La navigation doit changer selon l'environnement.

## MOBILE

Conserver si pertinent :

```text
BottomNavigationBar
```

ou :

```text
NavigationBar
```

Mais uniquement si les destinations principales sont adaptées à ce modèle.

---

## TABLETTE

Selon le nombre de destinations :

* `NavigationRail`
* `Drawer`
* navigation compacte
* sidebar réduite

---

## DESKTOP / WEB

Ne pas conserver automatiquement la Bottom Navigation.

Évaluer selon le produit :

* `NavigationRail`
* Sidebar
* Header Navigation
* combinaison Sidebar + TopBar
* navigation contextuelle

Le système de navigation doit être conçu pour :

* souris
* clavier
* grands écrans
* raccourcis potentiels

---

# PHASE 5 — SYSTÈME DE NAVIGATION UNIQUE

Créer, lorsque cela est pertinent, un composant adaptatif centralisé.

Conceptuellement :

```dart
AdaptiveScaffold(
  mobileNavigation: ...,
  tabletNavigation: ...,
  desktopNavigation: ...,
  body: ...,
)
```

L'objectif est d'éviter de répéter :

```dart
if (width < ...)
```

dans toutes les pages.

La logique d'adaptation doit être centralisée autant que possible.

---

# PHASE 6 — TRANSFORMATION DES BOTTOM SHEETS

Tous les `BottomSheet` existants doivent être audités.

Un Bottom Sheet mobile n'est pas forcément adapté au desktop.

Utiliser une logique similaire :

```text
MOBILE
↓
Bottom Sheet
```

```text
TABLET
↓
Centered Modal
ou Side Sheet
```

```text
DESKTOP
↓
Dialog
Side Panel
Modal
```

Le choix dépend de :

* la quantité de contenu ;
* le type d'action ;
* la fréquence d'utilisation ;
* la nécessité de conserver le contexte.

Créer si nécessaire un système :

```dart
AdaptiveOverlay.show(...)
```

capable de choisir automatiquement la meilleure présentation.

---

# PHASE 7 — CARDS

Les Cards ne doivent jamais grandir indéfiniment.

Identifier tous les cas utilisant implicitement :

```dart
width: double.infinity
```

ou :

```dart
Expanded
```

lorsque cela provoque une extension visuellement incorrecte sur grands écrans.

Utiliser selon le contexte :

* `ConstrainedBox`
* `SizedBox`
* `AspectRatio`
* `FractionallySizedBox`
* `GridView`
* `SliverGrid`
* `Wrap`
* `LayoutBuilder`

Les cartes doivent avoir une largeur cohérente.

Sur grand écran :

```text
Mauvais
──────────────────────────────────────────────
|                 CARD                       |
──────────────────────────────────────────────
```

Préférer :

```text
┌────────────┐ ┌────────────┐ ┌────────────┐
│    CARD    │ │    CARD    │ │    CARD    │
└────────────┘ └────────────┘ └────────────┘
```

Mais ne pas appliquer automatiquement une grille partout.

Certaines sections doivent conserver une largeur maximale et être centrées.

---

# PHASE 8 — CONTENU AVEC LARGEUR MAXIMALE

Identifier les pages dont le contenu devient trop large.

Utiliser un système de containers.

Conceptuellement :

```text
Mobile
→ padding compact

Tablet
→ largeur contrôlée

Desktop
→ maxWidth

Large Desktop
→ maxWidth adapté selon le type de contenu
```

Exemple :

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 1440,
    ),
    child: ...
  ),
)
```

Ne pas utiliser la même `maxWidth` pour tous les types de contenu.

Une page de lecture, un dashboard et une galerie peuvent avoir des contraintes différentes.

---

# PHASE 9 — BOUTONS

Auditer tous les boutons.

Identifier :

* boutons utilisant `double.infinity` ;
* boutons trop grands ;
* boutons trop petits ;
* CTA mobile qui deviennent absurdes sur desktop.

Logique souhaitée :

```text
Mobile
→ CTA large si nécessaire
→ parfois pleine largeur
```

```text
Desktop
→ bouton adapté au contenu
→ largeur naturelle
→ position contextuelle
```

Ne jamais conserver automatiquement un bouton pleine largeur sur un écran de 1920px.

---

# PHASE 10 — LAYOUTS QUI SE SUPERPOSENT

Identifier tous les problèmes liés à :

* `Stack`
* `Positioned`
* `Transform`
* `Expanded`
* contraintes fixes
* hauteur fixe
* largeur fixe
* scroll imbriqué
* `SingleChildScrollView`
* `Column` sans contrainte
* `ListView` dans un autre scroll

Les éléments ne doivent jamais se superposer involontairement.

Pour chaque problème :

1. Identifier la cause réelle.
2. Corriger les contraintes.
3. Ne pas simplement masquer le problème avec `overflow`.
4. Tester sur plusieurs tailles.

Ne pas utiliser :

```dart
Clip.none
```

ou des hacks similaires uniquement pour cacher un problème de layout.

---

# PHASE 11 — TRANSFORMATION DES COMPOSANTS

Pour chaque composant, décider explicitement :

## KEEP

Le composant reste essentiellement identique.

## ADAPT

La logique reste identique, mais :

* taille
* padding
* largeur
* orientation

changent.

## TRANSFORM

Le composant devient différent.

Exemple :

```text
Mobile
List verticale
```

↓

```text
Desktop
Grid ou Multi-column
```

---

## REPLACE

Une interaction mobile devient une interaction desktop.

Exemple :

```text
Bottom Sheet
```

↓

```text
Dialog
```

---

## COLLAPSE

Le contenu devient :

* accordion
* expandable section
* side panel

---

## HIDE

Uniquement pour les éléments secondaires ou décoratifs.

Une fonctionnalité importante ne doit jamais disparaître sans alternative.

---

# PHASE 12 — EXEMPLES DE TRANSFORMATIONS

## NAVIGATION

```text
Mobile
BottomNavigationBar
```

↓

```text
Tablet
NavigationRail
```

↓

```text
Desktop
Sidebar ou Header
```

---

## DETAILS

```text
Mobile
Bottom Sheet
```

↓

```text
Tablet
Modal
```

↓

```text
Desktop
Side Panel
```

---

## LISTES

```text
Mobile
ListView
```

↓

```text
Tablet
2 colonnes si pertinent
```

↓

```text
Desktop
Grid ou liste dense
```

---

## FORMULAIRES

```text
Mobile
Single Column
```

↓

```text
Tablet
Groupes logiques
```

↓

```text
Desktop
2 colonnes lorsque les champs sont indépendants
```

---

## STATISTIQUES

```text
Mobile
Carousel
ou liste horizontale
```

↓

```text
Tablet
2 x 2
```

↓

```text
Desktop
4 statistiques visibles
```

---

## TABLEAUX

```text
Mobile
Cards
```

↓

```text
Tablet
Liste dense / tableau scrollable
```

↓

```text
Desktop
DataTable ou tableau complet
```

---

# PHASE 13 — MOBILE NE DOIT PAS ÊTRE CASSÉ

L'objectif n'est pas uniquement d'améliorer le desktop.

Après chaque modification :

vérifier que :

* le mobile reste correct ;
* les pages ne se chevauchent pas ;
* la navigation fonctionne ;
* les Bottom Sheets fonctionnent toujours ;
* le scroll reste naturel ;
* les safe areas sont respectées ;
* les boutons restent accessibles ;
* le clavier ne masque pas les formulaires.

Ne jamais améliorer le desktop au détriment du mobile.

---

# PHASE 14 — INTERACTIONS

Adapter les interactions.

## MOBILE

Priorité :

* touch
* swipe
* bottom sheets
* zones tactiles
* navigation au pouce

## DESKTOP

Ajouter lorsque pertinent :

* hover
* cursor states
* tooltips
* clic droit si pertinent
* raccourcis clavier
* navigation clavier

Une interaction mobile ne doit pas être reproduite mécaniquement sur desktop.

---

# PHASE 15 — SOURIS ET CLAVIER

La version Web/Desktop doit être pensée pour :

```text
Mouse
Trackpad
Keyboard
```

Vérifier :

* hover
* focus
* tab navigation
* shortcuts si pertinent
* curseurs
* clics secondaires lorsque utiles

Ne pas concevoir la version desktop comme si l'utilisateur utilisait uniquement son doigt.

---

# PHASE 16 — TABLETTE

La tablette ne doit pas être oubliée.

Elle est située entre :

```text
Mobile
```

et :

```text
Desktop
```

mais ne doit pas être traitée comme :

```text
Mobile agrandi
```

ou :

```text
Desktop réduit
```

Créer une expérience intermédiaire.

Tester :

* portrait
* landscape

---

# PHASE 17 — PERFORMANCE

Ne pas créer des arbres de widgets complètement séparés pour chaque taille si seule une petite partie doit changer.

Favoriser :

* logique métier partagée ;
* widgets adaptatifs ;
* variantes ciblées ;
* reconstruction minimale ;
* lazy loading lorsque nécessaire.

Cependant :

> Si l'expérience desktop est réellement différente, il est acceptable d'avoir une présentation différente.

Ne sacrifie pas l'expérience utilisateur uniquement pour réduire quelques lignes de code.

---

# PHASE 18 — ARCHITECTURE DES WIDGETS

Favoriser une séparation :

```text
Feature Logic
        │
        ├── Mobile Presentation
        │
        ├── Tablet Presentation
        │
        └── Desktop Presentation
```

Mais partager :

```text
Models
State
Controllers
Repositories
Services
Business Logic
```

Le but est :

> partager la logique, adapter la présentation.

---

# PHASE 19 — NE PAS UTILISER UNIQUEMENT MEDIAQUERY PARTOUT

Éviter une application remplie de :

```dart
if (MediaQuery.of(context).size.width < 600)
```

dans chaque widget.

Créer une abstraction cohérente.

Par exemple :

* `AdaptiveLayout`
* `ResponsiveBuilder`
* `Breakpoint`
* `AdaptiveScaffold`

Centraliser les règles.

Les pages doivent rester lisibles et maintenables.

---

# PHASE 20 — TESTS OBLIGATOIRES

Tester l'application au minimum sur :

```text
320px
360px
375px
390px
414px

600px
768px
820px

1024px
1280px
1440px
1600px
1920px
```

Tester également :

* Mobile portrait
* Mobile landscape
* Tablet portrait
* Tablet landscape
* Laptop
* Desktop large

Tester les pages avec :

* contenu court ;
* contenu long ;
* beaucoup de données ;
* aucune donnée ;
* erreurs ;
* loading.

---

# PHASE 21 — MÉTHODE DE TRAVAIL

Ne pas modifier tout le projet brutalement.

Procéder dans cet ordre.

## ÉTAPE 1

Auditer l'application actuelle.

Identifier les composants problématiques.

Même ceux qui n'ont pas été explicitement listés.

---

## ÉTAPE 2

Créer ou améliorer l'infrastructure adaptative :

* breakpoints ;
* adaptive layout ;
* content constraints ;
* navigation system.

---

## ÉTAPE 3

Corriger le Shell principal de l'application :

```text
Scaffold
Navigation
AppBar
Sidebar
Content Area
Overlays
```

---

## ÉTAPE 4

Adapter les composants partagés :

* Cards
* Buttons
* Lists
* Dialogs
* Bottom Sheets
* Forms
* Tables

---

## ÉTAPE 5

Adapter les pages une par une.

---

## ÉTAPE 6

Tester chaque modification sur :

* Mobile
* Tablet
* Desktop

---

# PHASE 22 — CRITÈRE DE VALIDATION

Une page n'est pas considérée comme terminée simplement parce que :

```text
elle ne déborde plus
```

Elle doit également :

* utiliser intelligemment l'espace ;
* avoir une hiérarchie adaptée ;
* ne pas avoir de composants excessivement larges ;
* ne pas avoir de boutons disproportionnés ;
* posséder une navigation adaptée ;
* posséder des interactions adaptées au device ;
* fonctionner avec touch et souris ;
* rester visuellement cohérente ;
* conserver les fonctionnalités existantes.

---

# RÈGLE ULTIME

Ne traite jamais cette tâche comme :

> « Ajouter quelques MediaQuery pour rendre Flutter responsive. »

Traite-la comme :

> **Transformer une application mobile Flutter existante en un produit réellement multi-plateforme.**

La logique métier reste partagée.

Les données restent partagées.

Les fonctionnalités restent partagées.

Mais :

```text
MOBILE
≠
TABLET
≠
DESKTOP
```

Ils utilisent le même produit.

Mais ils peuvent utiliser :

* une navigation différente ;
* un layout différent ;
* des composants différents ;
* des interactions différentes ;
* une densité différente ;
* une hiérarchie différente.

## OBJECTIF FINAL

Après l'implémentation :

### Mobile

L'utilisateur doit avoir l'impression :

> « Cette application a été conçue pour mon téléphone. »

### Tablet

L'utilisateur doit avoir l'impression :

> « Cette interface utilise parfaitement l'espace disponible. »

### Desktop / Web

L'utilisateur doit avoir l'impression :

> « C'est une véritable application desktop/web, pas une application mobile agrandie. »

---

# CONSIGNE FINALE À L'AGENT

Commence par analyser l'intégralité de l'interface existante.

Ne te limite pas aux problèmes explicitement listés.

Détecte également les problèmes de conception adaptative que l'utilisateur n'a pas encore identifiés.

Avant chaque transformation importante :

1. Comprendre la fonction du composant.
2. Identifier son comportement actuel.
3. Déterminer son comportement idéal sur Mobile.
4. Déterminer son comportement idéal sur Tablet.
5. Déterminer son comportement idéal sur Desktop.
6. Choisir la stratégie appropriée :

   * KEEP
   * ADAPT
   * TRANSFORM
   * REPLACE
   * COLLAPSE
   * MERGE
   * HIDE

Ensuite, implémente progressivement les améliorations.

**Ne cherche pas simplement à faire tenir l'interface dans toutes les tailles.**

**Fais en sorte que chaque taille donne l'impression d'avoir été conçue intentionnellement pour elle.**




# ADAPTIVE ROUTING & PLATFORM-AWARE NAVIGATION

## PROBLÈME

L'application Flutter existante a été principalement conçue pour une navigation mobile.

Actuellement, une action peut fonctionner selon ce modèle :

```text
User clicks button
        ↓
Navigator.push()
        ↓
New Fullscreen Page
```

Cette logique ne doit pas être automatiquement reproduite sur Desktop Web.

Une même action utilisateur peut nécessiter une présentation différente selon la plateforme.

Le routing doit donc devenir **platform-aware** et **context-aware**.

---

# PRINCIPE FONDAMENTAL

Ne pas penser uniquement :

> « Vers quelle route dois-je naviguer ? »

Mais également :

> « Quelle est la meilleure manière de présenter cette destination sur ce device et dans ce contexte ? »

Une destination peut être affichée comme :

* Fullscreen Page
* Nested Page
* Dialog
* Modal
* Side Panel
* Split View
* Detail Panel
* Bottom Sheet
* Fullscreen Overlay

selon :

* la taille de l'écran ;
* le contexte utilisateur ;
* la complexité du contenu ;
* la nécessité de conserver la page précédente visible ;
* la plateforme.

---

# 1 — NAVIGATION MOBILE

Sur mobile, privilégier une navigation claire et séquentielle.

Exemple :

```text
Products Page
      ↓
User clicks Product
      ↓
Product Details Page
```

Le changement de page plein écran est naturel.

L'utilisateur dispose généralement :

```text
← Back
```

pour revenir à la liste.

La navigation mobile doit privilégier :

* navigation hiérarchique ;
* écran plein ;
* retour clair ;
* concentration sur une tâche.

---

# 2 — NAVIGATION DESKTOP WEB

Sur Desktop, ne pas systématiquement ouvrir une nouvelle page plein écran.

Avant toute navigation, analyser si l'utilisateur bénéficie davantage de :

## OPTION A — NOUVELLE PAGE

Utiliser lorsque la destination représente une tâche importante ou complexe.

Exemples :

* Dashboard
* Paramètres complets
* Éditeur complexe
* Page analytique
* Workflow complet

---

## OPTION B — SIDE PANEL

Utiliser lorsque l'utilisateur doit consulter ou modifier un élément sans perdre le contexte.

Exemple :

```text
┌──────────────┬───────────────────────┐
│              │                       │
│ Product List │    Product Details    │
│              │                       │
│ Product 1    │    Image              │
│ Product 2    │    Description        │
│ Product 3    │    Actions            │
│              │                       │
└──────────────┴───────────────────────┘
```

---

## OPTION C — SPLIT VIEW

Utiliser lorsque :

* une liste et un détail sont fortement liés ;
* l'utilisateur doit comparer plusieurs éléments ;
* le contexte doit rester visible.

Exemple :

```text
┌────────────────────┬─────────────────────────┐
│                    │                         │
│       LIST         │         DETAILS         │
│                    │                         │
│ Item 1             │ Selected Item           │
│ Item 2             │                         │
│ Item 3             │                         │
│                    │                         │
└────────────────────┴─────────────────────────┘
```

---

## OPTION D — DIALOG

Utiliser pour :

* création rapide ;
* modification rapide ;
* confirmation ;
* actions ponctuelles.

Exemple :

```text
Background
       ↓

        ┌─────────────────────┐
        │ Create Product      │
        │                     │
        │ Name                │
        │ Price               │
        │                     │
        │ [Cancel] [Create]   │
        └─────────────────────┘
```

---

# 3 — ADAPTIVE DESTINATION PRESENTATION

Une fonctionnalité ne doit pas être définie uniquement par une route.

Séparer :

```text
Destination
```

de :

```text
Presentation
```

Exemple conceptuel :

```text
Product Details
        │
        ├── Mobile
        │       → Fullscreen Route
        │
        ├── Tablet
        │       → Modal ou Page
        │
        └── Desktop
                → Side Panel ou Split View
```

La donnée et la logique métier restent identiques.

Seule la manière d'accéder à cette destination change.

---

# 4 — ADAPTIVE NAVIGATION DECISION

Créer une couche capable de décider comment présenter une destination.

Conceptuellement :

```text
User Action
      ↓
Adaptive Navigation
      ↓
┌─────────────┐
│ Screen Type │
└─────────────┘
      ↓
Mobile
→ Full Page

Tablet
→ Page ou Modal

Desktop
→ Page / Dialog / Side Panel / Split View
```

Éviter de placer directement :

```dart
Navigator.push(...)
```

dans tous les boutons de l'application.

Centraliser lorsque pertinent la logique de navigation adaptative.

---

# 5 — EXEMPLE CONCEPTUEL

Au lieu de faire :

```dart
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailsPage(
        product: product,
      ),
    ),
  );
}
```

Créer une logique conceptuelle :

```dart
onPressed: () {
  AdaptiveNavigation.openProduct(
    context,
    product,
  );
}
```

Puis :

```text
Mobile
→ Navigator.push()

Tablet
→ Modal ou Page

Desktop
→ Side Panel ou Split View
```

L'implémentation exacte doit respecter l'architecture existante.

Ne pas ajouter une abstraction inutilement complexe si le projet est petit.

---

# 6 — ROUTING ET URL WEB

Sur Web/Desktop, le routing doit également respecter les conventions Web.

Les pages importantes doivent disposer d'URLs cohérentes lorsque cela est pertinent.

Exemple :

```text
/products
/products/123
/settings
/profile
```

Même lorsqu'un détail est affiché dans un Side Panel ou un Split View, réfléchir à la possibilité de conserver un état navigable.

Exemple :

```text
/products
```

puis :

```text
/products/123
```

Le changement d'URL peut représenter la sélection actuelle.

Ainsi :

* refresh ;
* partage de lien ;
* navigation navigateur ;
* bookmark ;

restent cohérents.

---

# 7 — BROWSER HISTORY

La version Web doit respecter :

```text
Browser Back
Browser Forward
Refresh
Direct URL
Deep Link
```

Ne pas traiter l'application Web uniquement comme une application mobile dans Chrome.

Vérifier que :

* le bouton Back fonctionne ;
* le Forward fonctionne lorsque pertinent ;
* une URL directe fonctionne ;
* le refresh ne détruit pas inutilement le contexte ;
* un utilisateur peut partager une destination importante.

---

# 8 — NAVIGATION SHELL

Créer un shell adaptatif.

## MOBILE

```text
┌──────────────────────┐
│ AppBar               │
├──────────────────────┤
│                      │
│                      │
│       CONTENT        │
│                      │
│                      │
├──────────────────────┤
│ Home Search Add User │
└──────────────────────┘
```

## DESKTOP

```text
┌───────────────┬──────────────────────────────────┐
│               │ Top Bar                          │
│   SIDEBAR     ├──────────────────────────────────┤
│               │                                  │
│   Navigation  │                                  │
│               │            CONTENT               │
│               │                                  │
│               │                                  │
└───────────────┴──────────────────────────────────┘
```

Le contenu peut ensuite disposer de ses propres layouts.

---

# 9 — PAGE TRANSITIONS

Les transitions doivent également être adaptatives.

## MOBILE

Utiliser lorsque pertinent :

* slide ;
* Cupertino-style transition ;
* navigation push/pop.

## DESKTOP WEB

Éviter de simuler systématiquement une transition mobile.

Privilégier :

* fade subtil ;
* changement de contenu ;
* panel expansion ;
* modal transition courte.

Une animation de navigation doit correspondre à la structure de l'interface.

---

# 10 — MASTER DETAIL EXPERIENCE

Identifier toutes les pages possédant une relation :

```text
Collection
        ↓
Item
        ↓
Details
```

Exemples :

* Products → Product Details
* Messages → Conversation
* Users → User Profile
* Events → Event Details
* Orders → Order Details

Sur mobile :

```text
Collection
→ New Page
→ Details
```

Sur desktop, évaluer :

```text
Collection | Details
```

comme expérience Split View.

Ne pas l'appliquer systématiquement.

Utiliser le Split View uniquement lorsqu'il améliore réellement :

* la productivité ;
* la comparaison ;
* la vitesse de navigation ;
* la conservation du contexte.

---

# 11 — NAVIGATION DES ACTIONS RAPIDES

Toutes les actions ne doivent pas créer une route.

Identifier les boutons qui devraient ouvrir :

* Dialog ;
* Side Sheet ;
* Popover ;
* Context Menu ;
* Bottom Sheet mobile.

Exemple :

```text
MOBILE

[ Filter ]
      ↓
Bottom Sheet
```

```text
DESKTOP

[ Filter ]
      ↓
Popover
ou Filter Sidebar
```

---

# 12 — PAGE RESPONSIBILITY

Pour chaque page, déterminer son type.

## FULL DESTINATION

Une vraie page indépendante.

Exemples :

* Dashboard
* Settings
* Analytics

---

## DETAIL DESTINATION

Peut être affichée différemment selon le device.

Exemples :

* Product Detail
* User Detail
* Order Detail

---

## ACTION DESTINATION

Ne nécessite pas forcément une page.

Exemples :

* Create Item
* Edit Item
* Filter
* Quick Settings

Peut devenir :

```text
Mobile
→ Bottom Sheet ou Full Page
```

```text
Desktop
→ Dialog ou Side Panel
```

---

# 13 — AUDIT DU ROUTING EXISTANT

Auditer toutes les navigations existantes.

Identifier :

* tous les `Navigator.push` ;
* tous les `pushNamed` ;
* tous les appels GoRouter ou système équivalent ;
* les navigations imbriquées ;
* les Bottom Sheets ;
* les Dialogs ;
* les transitions.

Pour chaque navigation, déterminer :

```text
ACTION
↓
CURRENT PRESENTATION
↓
MOBILE IDEAL
↓
TABLET IDEAL
↓
DESKTOP IDEAL
```

Ne pas modifier aveuglément toutes les navigations.

---

# RÈGLE FINALE

Une action utilisateur doit conserver la même intention.

Mais pas obligatoirement la même transition ni le même type de navigation.

```text
Même action
+
Même données
+
Même logique métier
≠
Même présentation
```

Sur mobile :

> La navigation peut être séquentielle.

Sur Desktop :

> La navigation peut devenir contextuelle, parallèle ou persistante.

L'objectif est que l'utilisateur Desktop ait accès à une expérience adaptée à un grand écran, tout en conservant une architecture Flutter commune.

**Ne transforme donc pas simplement les pages mobiles en pages web plus larges.**

Analyse chaque destination et décide si elle doit devenir :

* une page ;
* un dialog ;
* un side panel ;
* une split view ;
* une overlay ;
* une destination persistante.

Le routing fait partie de l'expérience utilisateur.

Il doit donc lui aussi être adaptatif.
# INSTRUCTION D'APPLICATION — RESPONSIVE ADAPTIVE REDESIGN

Analyse l'intégralité de l'application actuellement ouverte dans ce projet.

Ne crée pas une nouvelle application.

Ne modifie pas la logique métier, les fonctionnalités, les données ou les flux existants sauf si cela est strictement nécessaire.

Ta mission est de **refondre entièrement l'expérience responsive de l'application existante**.

## MÉTHODE OBLIGATOIRE

Commence par analyser toutes les pages et tous les composants existants.

Pour chaque élément de l'interface, identifie :

* son rôle
* son importance
* son comportement actuel
* ses contraintes de largeur
* son comportement sur petits écrans
* son interaction principale

Ensuite, attribue à chaque composant l'une des stratégies suivantes :

* KEEP — conserver avec adaptation responsive
* ADAPT — conserver la logique mais modifier la présentation
* TRANSFORM — changer complètement sa forme selon le device
* MERGE — fusionner avec un autre élément
* COLLAPSE — rendre repliable
* HIDE — masquer lorsqu'il est secondaire
* REPLACE — remplacer par une interaction plus adaptée

---

# ANALYSE PAR DEVICE

Tu dois concevoir séparément :

## Desktop

Expérience riche.

Utiliser l'espace disponible intelligemment :

* multi-colonnes
* panneaux
* Bento Grid
* informations simultanées
* interactions hover
* raccourcis
* statistiques détaillées

## Laptop

Conserver la richesse mais réduire :

* les espaces
* la largeur des cartes
* les éléments décoratifs
* les informations secondaires visibles simultanément

## Tablette

Repenser l'interface pour le tactile.

Privilégier :

* zones tactiles larges
* drawers
* sections fusionnées
* cartes simplifiées
* navigation réduite

## Mobile

Ne jamais simplement réduire le desktop.

La version mobile doit ressembler à une véritable application.

Transformer lorsque nécessaire :

* Sidebars → Bottom Navigation ou Drawer
* Grids → Carousels
* Bento → Stack interactif
* Tableaux → Cards
* Formulaires longs → Wizard
* Comparatifs → Tabs
* FAQ → Accordion ou Bottom Sheet
* Timelines horizontales → Progression verticale
* Statistiques multiples → Carte principale avec navigation
* Menus complexes → Navigation fullscreen

---

# PROCESSUS D'IMPLÉMENTATION

## PHASE 1 — AUDIT

Analyse :

* toutes les pages
* tous les composants
* la navigation
* les layouts
* les cartes
* les tableaux
* les formulaires
* les modals
* les images
* les animations

Identifie précisément les éléments actuellement trop dépendants d'un layout desktop.

## PHASE 2 — RESPONSIVE FOUNDATION

Mettre en place ou améliorer :

* containers adaptatifs
* spacing system
* typography responsive
* breakpoints intelligents
* tailles tactiles
* gestion des overflow
* responsive images
* safe areas mobile

Ne pas multiplier les media queries arbitrairement.

Créer une logique cohérente et maintenable.

## PHASE 3 — NAVIGATION

Repenser la navigation selon chaque device.

Ne pas simplement cacher des éléments.

Créer une véritable stratégie :

Desktop → navigation complète

Tablet → navigation simplifiée / drawer

Mobile → navigation adaptée au pouce, bottom navigation ou fullscreen menu selon la structure de l'application.

## PHASE 4 — TRANSFORMATION DES COMPOSANTS

Pour chaque composant important, vérifier si sa structure actuelle est réellement adaptée au mobile.

Si ce n'est pas le cas, créer une variante responsive spécifique.

La logique métier et les données peuvent être partagées.

La présentation peut être différente.

Exemple conceptuel :

DesktopComponent
→ même données
→ même logique

MobileComponent
→ présentation différente
→ interactions tactiles
→ hiérarchie simplifiée

## PHASE 5 — PERFORMANCE

Sur mobile, réduire ou supprimer :

* illustrations décoratives inutiles
* animations lourdes
* effets GPU coûteux
* gros SVG inutiles
* contenu non visible immédiatement

Privilégier :

* lazy loading
* responsive images
* chargement progressif
* animations légères
* respect de prefers-reduced-motion

## PHASE 6 — VALIDATION

Tester chaque page sur plusieurs largeurs :

* 320px
* 360px
* 375px
* 390px
* 414px
* 480px
* 768px
* 820px
* 1024px
* 1280px
* 1440px
* 1920px

Tester également :

* portrait
* landscape
* contenu long
* données nombreuses
* empty states
* loading
* erreurs
* clavier mobile

---

# RÈGLE PRINCIPALE

Ne considère jamais qu'une page est responsive uniquement parce qu'elle ne déborde plus.

Une page est responsive uniquement lorsque son expérience est naturellement adaptée au contexte d'utilisation.

Pour chaque écran, pose la question :

> Quelle est l'information principale ?

Puis :

> Quelle est l'action principale ?

Puis :

> Quelle est la manière la plus naturelle d'afficher et d'utiliser cette fonctionnalité sur ce device ?

---

# CONTRAINTE DE DESIGN

Le résultat final doit sembler avoir été conçu séparément pour :

* Desktop
* Laptop
* Tablet
* Mobile

Tout en conservant une identité visuelle et une logique produit cohérentes.

Ne fais pas un simple travail de CSS.

Travaille comme un **Frontend Architect et UX Designer**.

Analyse.

Priorise.

Transforme les composants lorsque nécessaire.

Optimise les interactions.

Respecte la logique métier existante.

L'objectif final est le suivant :

> Un utilisateur mobile doit avoir l'impression d'utiliser une application pensée pour mobile.

> Un utilisateur desktop doit avoir l'impression d'utiliser une application pensée pour desktop.

> Les deux doivent utiliser le même produit, mais pas nécessairement la même expérience visuelle.
