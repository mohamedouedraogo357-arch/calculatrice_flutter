/*
 * ========================================================================
 * APPLICATION CALCULATRICE FLUTTER
 * ========================================================================
 *
 * FONCTIONNEMENT GÉNÉRAL :
 * Cette application est une calculatrice complète développée en Flutter.
 * Elle permet d'effectuer les opérations arithmétiques de base (addition,
 * soustraction, multiplication, division) ainsi que des opérations
 * spéciales (pourcentage, changement de signe, décimales).
 *
 * ARCHITECTURE :
 * - Interface utilisateur : fond noir avec boutons circulaires
 * - Affichage double : opération en cours (petit texte gris) + résultat (grand texte blanc)
 * - Gestion d'état avec StatefulWidget pour réactivité en temps réel
 * - Protection contre les erreurs (division par zéro, arrondis flottants)
 *
 * PRINCIPALES FONCTIONS :
 * - onBoutonClick() : Gère tous les clics de boutons et la logique métier
 * - calculer() : Effectue les calculs arithmétiques
 * - buildButton() : Construit les boutons circulaires normaux
 * - buildVerticalButton() : Construit le bouton "=" vertical (2 rangées)
 *
 * CHOIX D'IMPLÉMENTATION DU BOUTON % :
 * Le bouton "%" divise le nombre affiché par 100 (convertit en pourcentage).
 * Exemple : 50% → 0.5 (utile pour calculer 50% de 200 = 200 × 0.5 = 100)
 * Cette approche est standard sur les calculatrices iOS/Android.
 * Alternative non retenue : calcul de pourcentage relatif (ex: 10% de 50)
 *
 * ========================================================================
 */

import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatriceApp());
}

/// Widget racine de l'application
/// Configure le thème sombre et lance l'écran principal
class CalculatriceApp extends StatelessWidget {
  const CalculatriceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculatrice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatriceScreen(),
    );
  }
}

/// Widget principal de la calculatrice
/// Gère l'interface utilisateur et la structure de la page
class CalculatriceScreen extends StatefulWidget {
  const CalculatriceScreen({Key? key}) : super(key: key);

  @override
  State<CalculatriceScreen> createState() => _CalculatriceScreenState();
}

/// État de la calculatrice
/// Contient toute la logique métier et la gestion des calculs
class _CalculatriceScreenState extends State<CalculatriceScreen> {
  // ========================================================================
  // VARIABLES D'ÉTAT
  // ========================================================================

  /// Résultat affiché à l'écran (nombre en cours de saisie ou résultat final)
  String affichageResultat = '0';

  /// Opération en cours affichée en petit au-dessus du résultat
  /// Exemple : "10 +" ou "5 × 2 ="
  String operationEnCours = '';

  /// Premier nombre stocké lors d'une opération (ex: dans "5 + 3", c'est le 5)
  double? premierNombre;

  /// Opérateur en cours (+, -, ×, ÷)
  String? operateur;

  /// Indique si on démarre un nouveau calcul (pour remplacer vs ajouter des chiffres)
  bool nouveauCalcul = true;

  // ========================================================================
  // FONCTION PRINCIPALE : GESTION DES CLICS
  // ========================================================================

  /// Gère tous les clics sur les boutons de la calculatrice
  ///
  /// Cette fonction centrale contient toute la logique métier :
  /// - Réinitialisation (C)
  /// - Calcul du résultat (=)
  /// - Stockage des opérateurs (+, -, ×, ÷)
  /// - Opérations spéciales (%, +/-, .)
  /// - Saisie des chiffres (0-9)
  ///
  /// Paramètre [valeur] : Texte du bouton cliqué
  void onBoutonClick(String valeur) {
    setState(() {
      switch (valeur) {
      // --------------------------------------------------------------------
      // BOUTON C : RÉINITIALISATION COMPLÈTE
      // --------------------------------------------------------------------
        case 'C':
          affichageResultat = '0';
          operationEnCours = '';
          premierNombre = null;
          operateur = null;
          nouveauCalcul = true;
          break;

      // --------------------------------------------------------------------
      // BOUTON = : CALCUL DU RÉSULTAT FINAL
      // --------------------------------------------------------------------
        case '=':
        // Vérification qu'une opération est en cours
          if (premierNombre != null && operateur != null) {
            double secondNombre = double.parse(affichageResultat);
            double? resultat = calculer(premierNombre!, operateur!, secondNombre);

            // Gestion de la division par zéro
            if (resultat == null) {
              affichageResultat = 'Erreur';
              operationEnCours = '';
              premierNombre = null;
              operateur = null;
              nouveauCalcul = true;
              break;
            }

            // Arrondi à 10 décimales pour éviter les erreurs de précision
            // Exemple : 0.1 + 0.2 donne 0.30000000000000004 → arrondi à 0.3
            resultat = double.parse(resultat.toStringAsFixed(10));

            // Affichage de l'opération complète
            operationEnCours = '$premierNombre $operateur $secondNombre =';

            // Formatage du résultat : enlève ".0" pour les nombres entiers
            // Exemple : 10.0 → "10" mais 10.5 → "10.5"
            if (resultat == resultat.toInt()) {
              affichageResultat = resultat.toInt().toString();
            } else {
              affichageResultat = resultat.toString();
            }

            // Réinitialisation pour un nouveau calcul
            premierNombre = null;
            operateur = null;
            nouveauCalcul = true;
          }
          break;

      // --------------------------------------------------------------------
      // OPÉRATEURS : +, -, ×, ÷
      // --------------------------------------------------------------------
        case '+':
        case '-':
        case '×':
        case '÷':
        // Si une opération est déjà en cours, on calcule d'abord le résultat intermédiaire
        // Exemple : 5 + 3 + 2 → calcule d'abord 5+3=8, puis prépare 8+2
          if (premierNombre != null && operateur != null && !nouveauCalcul) {
            double secondNombre = double.parse(affichageResultat);
            double? resultat = calculer(premierNombre!, operateur!, secondNombre);

            // Gestion de la division par zéro
            if (resultat == null) {
              affichageResultat = 'Erreur';
              operationEnCours = '';
              premierNombre = null;
              operateur = null;
              nouveauCalcul = true;
              break;
            }

            // Arrondi pour éviter les erreurs de précision
            resultat = double.parse(resultat.toStringAsFixed(10));

            // Formatage du résultat
            if (resultat == resultat.toInt()) {
              affichageResultat = resultat.toInt().toString();
            } else {
              affichageResultat = resultat.toString();
            }
          }

          // Stockage du nombre actuel et de l'opérateur
          premierNombre = double.parse(affichageResultat);
          operateur = valeur;
          operationEnCours = '$premierNombre $operateur';
          nouveauCalcul = true;
          break;

      // --------------------------------------------------------------------
      // BOUTON % : CONVERSION EN POURCENTAGE
      // --------------------------------------------------------------------
      // CHOIX D'IMPLÉMENTATION :
      // Le bouton % divise le nombre par 100 pour le convertir en pourcentage.
      //
      // JUSTIFICATION :
      // - Standard iOS/Android : comportement familier aux utilisateurs
      // - Utilisation pratique : 50% → 0.5, puis 200 × 0.5 = 100
      // - Simplicité : une seule opération claire et prévisible
      //
      // ALTERNATIVE NON RETENUE :
      // Calcul de pourcentage contextuel (ex: "10% de 50")
      // Raison : nécessite de deviner l'intention (ajouter? multiplier?)
      //
      // EXEMPLES D'USAGE :
      // - Calculer 20% de 150 : 20 [%] × 150 [=] → 30
      // - Ajouter 5% : 100 [+] 5 [%] [=] → 100.05
      // --------------------------------------------------------------------
        case '%':
          double nombre = double.parse(affichageResultat);
          double resultat = nombre / 100; // Division par 100

          // Formatage du résultat
          if (resultat == resultat.toInt()) {
            affichageResultat = resultat.toInt().toString();
          } else {
            affichageResultat = resultat.toString();
          }
          nouveauCalcul = true;
          break;

      // --------------------------------------------------------------------
      // BOUTON . : AJOUT DU POINT DÉCIMAL
      // --------------------------------------------------------------------
        case '.':
        // Évite d'avoir plusieurs points dans un même nombre
          if (!affichageResultat.contains('.')) {
            affichageResultat += '.';
          }
          nouveauCalcul = false;
          break;

      // --------------------------------------------------------------------
      // BOUTON +/- : CHANGEMENT DE SIGNE
      // --------------------------------------------------------------------
        case '+/-':
          if (affichageResultat != '0') {
            // Inverse le signe du nombre
            if (affichageResultat.startsWith('-')) {
              // Nombre négatif → positif (enlève le "-")
              affichageResultat = affichageResultat.substring(1);
            } else {
              // Nombre positif → négatif (ajoute le "-")
              affichageResultat = '-$affichageResultat';
            }
          }
          break;

      // --------------------------------------------------------------------
      // CHIFFRES : 0-9
      // --------------------------------------------------------------------
        default:
        // Si on démarre un nouveau calcul ou si l'affichage est "0"
          if (nouveauCalcul || affichageResultat == '0') {
            // Remplace l'affichage par le nouveau chiffre
            affichageResultat = valeur;
            nouveauCalcul = false;
          } else {
            // Ajoute le chiffre à la suite
            affichageResultat += valeur;
          }
          break;
      }
    });
  }

  // ========================================================================
  // FONCTION DE CALCUL
  // ========================================================================

  /// Effectue le calcul arithmétique entre deux nombres
  ///
  /// Cette fonction gère les 4 opérations de base et protège contre
  /// la division par zéro en retournant null.
  ///
  /// Paramètres :
  /// - [a] : Premier nombre (opérande gauche)
  /// - [op] : Opérateur (+, -, ×, ÷)
  /// - [b] : Second nombre (opérande droite)
  ///
  /// Retourne : Le résultat du calcul, ou null si division par zéro
  double? calculer(double a, String op, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
      // Protection contre la division par zéro
        if (b == 0) {
          return null; // Retourne null pour indiquer une erreur
        }
        return a / b;
      default:
        return 0;
    }
  }

  // ========================================================================
  // WIDGETS : CONSTRUCTION DES BOUTONS
  // ========================================================================

  /// Construit un bouton circulaire normal (80x80 pixels)
  ///
  /// Utilisé pour tous les boutons sauf le "=" qui est vertical.
  ///
  /// Paramètres :
  /// - [text] : Texte affiché sur le bouton
  /// - [color] : Couleur du bouton (gris par défaut, orange pour opérateurs)
  Widget buildButton(String text, {Color? color}) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: () => onBoutonClick(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFF505050), // Gris foncé par défaut
          shape: const CircleBorder(), // Forme circulaire
          padding: EdgeInsets.zero,
          elevation: 0, // Pas d'ombre
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Construit un bouton vertical (80x172 pixels)
  ///
  /// Utilisé uniquement pour le bouton "=" qui prend 2 rangées de hauteur.
  /// Cela permet un design moderne et facilite l'accès au bouton principal.
  ///
  /// Paramètres :
  /// - [text] : Texte affiché sur le bouton
  /// - [color] : Couleur du bouton (orange par défaut)
  Widget buildVerticalButton(String text, {Color? color}) {
    return Container(
      width: 80,
      height: 172, // 80 * 2 + 12 (marges entre les boutons)
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: () => onBoutonClick(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // Coins arrondis
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // INTERFACE UTILISATEUR
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------------
            // ZONE D'AFFICHAGE (en haut)
            // ----------------------------------------------------------------
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Opération en cours (petit texte gris)
                    // Exemple : "10 + 5 ="
                    Text(
                      operationEnCours,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Résultat (grand texte blanc)
                    // S'adapte automatiquement si le nombre est trop long
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        affichageResultat,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // ZONE DES BOUTONS (en bas)
            // ----------------------------------------------------------------
            // Disposition respectant la maquette :
            // Rangée 1 : C    %    ÷    ×
            // Rangée 2 : 7    8    9    -
            // Rangée 3 : 4    5    6    ┃
            // Rangée 4 : 1    2    3    ┃ +
            // Rangée 5 : +/-  0    .    ┃ =  (bouton vertical)
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
              child: Column(
                children: [
                  // Rangée 1 : C, %, ÷, ×
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildButton('C', color: const Color(0xFF505050)),
                      buildButton('%', color: const Color(0xFF505050)),
                      buildButton('÷', color: Colors.orange),
                      buildButton('×', color: Colors.orange),
                    ],
                  ),

                  // Rangée 2 : 7, 8, 9, -
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildButton('7'),
                      buildButton('8'),
                      buildButton('9'),
                      buildButton('-', color: Colors.orange),
                    ],
                  ),

                  // Rangées 3-5 : Structure spéciale pour le bouton = vertical
                  // La colonne gauche contient 3 rangées de 3 boutons
                  // La colonne droite contient le + et le = vertical
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colonne gauche : chiffres 4-6, 1-3, et +/- 0 .
                      Column(
                        children: [
                          Row(
                            children: [
                              buildButton('4'),
                              buildButton('5'),
                              buildButton('6'),
                            ],
                          ),
                          Row(
                            children: [
                              buildButton('1'),
                              buildButton('2'),
                              buildButton('3'),
                            ],
                          ),
                          Row(
                            children: [
                              buildButton('+/-', color: const Color(0xFF505050)),
                              buildButton('0'),
                              buildButton('.'),
                            ],
                          ),
                        ],
                      ),
                      // Colonne droite : + et = vertical
                      Column(
                        children: [
                          buildButton('+', color: Colors.orange),
                          buildVerticalButton('=', color: Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}