# Configuration des builds Android Flex

Le workflow `.github/workflows/flutter-android.yml` construit l'APK Android et publie le fichier comme artefact GitHub Actions.

## URL de l'API

La valeur transmise à Flutter est la variable de dépôt GitHub Actions :

- Nom : `API_BASE_URL`
- Valeur actuelle : `https://flex-1wlr.onrender.com/api/v1`

Pour la définir ou la modifier :

1. Ouvrir le dépôt GitHub **somboro08/flex**.
2. Aller dans **Settings → Secrets and variables → Actions → Variables**.
3. Cliquer sur **New repository variable**.
4. Saisir `API_BASE_URL` comme nom et l'URL publique de l'API comme valeur.

Cette URL est une configuration publique, pas un secret. Ne placez aucun token, mot de passe ou clé privée dans cette variable.

Si la variable n'est pas encore définie, le workflow utilise temporairement l'URL Render actuelle comme valeur par défaut. Les builds de production refusent les URL qui ne commencent pas par `https://`.

## Récupérer l'APK

Après un push sur `main` ou sur la branche de configuration, ou après une exécution manuelle :

1. Ouvrir l'onglet **Actions**.
2. Sélectionner le workflow **Flutter Android CI**.
3. Ouvrir une exécution terminée.
4. Télécharger l'artefact **flex-android-release**.

## Commandes locales

Développement sur émulateur Android :

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Build Android de production :

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://flex-1wlr.onrender.com/api/v1
```

Le workflow comporte deux contrôles séparés : analyse/tests Flutter et compilation de l'APK. L'APK est publié même si le job d'analyse échoue, afin de pouvoir diagnostiquer les deux résultats indépendamment.
