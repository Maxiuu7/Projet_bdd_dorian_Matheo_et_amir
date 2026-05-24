"""
ALSI61 — Centre de Stages de Pilotage
Application Flask (Partie 3)
Auteurs : Matheo DOS SANTOS — Dorian FEREOL
"""

from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from config import DB_CONFIG

app = Flask(__name__)
app.secret_key = 'centre_pilotage_secret_key'


# ── helpers ──────────────────────────────────────────────────────────────────

def get_db():
    """Ouvre une connexion MySQL."""
    return mysql.connector.connect(**DB_CONFIG)


# ── PAGE D'ACCUEIL ───────────────────────────────────────────────────────────

@app.route('/')
def index():
    """Dashboard : quelques chiffres clés."""
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("SELECT COUNT(*) AS total FROM PILOTE")
    nb_pilotes = cur.fetchone()['total']

    cur.execute("SELECT COUNT(*) AS total FROM STAGE")
    nb_stages = cur.fetchone()['total']

    cur.execute("SELECT COUNT(*) AS total FROM INSCRIPTION")
    nb_inscriptions = cur.fetchone()['total']

    cur.execute("SELECT COUNT(*) AS total FROM VEHICULE")
    nb_vehicules = cur.fetchone()['total']

    cur.close()
    db.close()
    return render_template('index.html',
                           nb_pilotes=nb_pilotes,
                           nb_stages=nb_stages,
                           nb_inscriptions=nb_inscriptions,
                           nb_vehicules=nb_vehicules)


# ══════════════════════════════════════════════════════════════════════════════
#  CRUD PILOTES
# ══════════════════════════════════════════════════════════════════════════════

# ── 2. Lister tous les pilotes ───────────────────────────────────────────────

@app.route('/pilotes')
def pilotes_list():
    """Liste de tous les pilotes, triés par nom puis prénom."""
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT id_pilote, nom_pilote, prenom_pilote, date_naissance, niveau, email
        FROM PILOTE
        ORDER BY nom_pilote ASC, prenom_pilote ASC
    """)
    pilotes = cur.fetchall()
    cur.close()
    db.close()
    return render_template('pilotes/list.html', pilotes=pilotes)


# ── 1. Ajouter un pilote ────────────────────────────────────────────────────

@app.route('/pilotes/ajouter', methods=['GET', 'POST'])
def pilotes_add():
    """Formulaire d'ajout d'un nouveau pilote."""
    if request.method == 'POST':
        nom = request.form['nom_pilote']
        prenom = request.form['prenom_pilote']
        date_naissance = request.form['date_naissance']
        niveau = request.form['niveau']
        email = request.form['email']

        db = get_db()
        cur = db.cursor()
        try:
            cur.execute("""
                INSERT INTO PILOTE (nom_pilote, prenom_pilote, date_naissance, niveau, email)
                VALUES (%s, %s, %s, %s, %s)
            """, (nom, prenom, date_naissance, niveau, email))
            db.commit()
            flash('Pilote ajouté avec succès !', 'success')
        except mysql.connector.Error as err:
            db.rollback()
            flash(f'Erreur : {err}', 'danger')
        finally:
            cur.close()
            db.close()
        return redirect(url_for('pilotes_list'))

    return render_template('pilotes/form.html', pilote=None, action='Ajouter')


# ── 4. Modifier un pilote ───────────────────────────────────────────────────

@app.route('/pilotes/modifier/<int:id>', methods=['GET', 'POST'])
def pilotes_edit(id):
    """Formulaire de modification d'un pilote existant."""
    db = get_db()
    cur = db.cursor(dictionary=True)

    if request.method == 'POST':
        nom = request.form['nom_pilote']
        prenom = request.form['prenom_pilote']
        date_naissance = request.form['date_naissance']
        niveau = request.form['niveau']
        email = request.form['email']

        try:
            cur.execute("""
                UPDATE PILOTE
                SET nom_pilote=%s, prenom_pilote=%s, date_naissance=%s, niveau=%s, email=%s
                WHERE id_pilote=%s
            """, (nom, prenom, date_naissance, niveau, email, id))
            db.commit()
            flash('Pilote modifié avec succès !', 'success')
        except mysql.connector.Error as err:
            db.rollback()
            flash(f'Erreur : {err}', 'danger')
        finally:
            cur.close()
            db.close()
        return redirect(url_for('pilotes_list'))

    cur.execute("SELECT * FROM PILOTE WHERE id_pilote = %s", (id,))
    pilote = cur.fetchone()
    cur.close()
    db.close()

    if not pilote:
        flash('Pilote introuvable.', 'danger')
        return redirect(url_for('pilotes_list'))

    return render_template('pilotes/form.html', pilote=pilote, action='Modifier')


# ── 5. Supprimer un pilote ───────────────────────────────────────────────────

@app.route('/pilotes/supprimer/<int:id>', methods=['POST'])
def pilotes_delete(id):
    """Supprime un pilote (et ses inscriptions via CASCADE)."""
    db = get_db()
    cur = db.cursor()
    try:
        cur.execute("DELETE FROM PILOTE WHERE id_pilote = %s", (id,))
        db.commit()
        flash('Pilote supprimé.', 'success')
    except mysql.connector.Error as err:
        db.rollback()
        flash(f'Erreur : {err}', 'danger')
    finally:
        cur.close()
        db.close()
    return redirect(url_for('pilotes_list'))


# ── 8. Détail d'un pilote avec données associées ────────────────────────────

@app.route('/pilotes/<int:id>')
def pilotes_detail(id):
    """Affiche le détail d'un pilote + ses inscriptions, stages et véhicules."""
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("SELECT * FROM PILOTE WHERE id_pilote = %s", (id,))
    pilote = cur.fetchone()

    if not pilote:
        cur.close()
        db.close()
        flash('Pilote introuvable.', 'danger')
        return redirect(url_for('pilotes_list'))

    # inscriptions avec le nom du stage, du circuit et du véhicule
    cur.execute("""
        SELECT i.date_inscription, i.statut,
               s.nom_stage, s.date_debut, s.prix,
               c.nom_circuit, c.ville,
               v.marque, v.modele, v.puissance_cv
        FROM INSCRIPTION i
        INNER JOIN STAGE s ON i.id_stage = s.id_stage
        INNER JOIN CIRCUIT c ON s.id_circuit = c.id_circuit
        INNER JOIN VEHICULE v ON i.id_vehicule = v.id_vehicule
        WHERE i.id_pilote = %s
        ORDER BY s.date_debut DESC
    """, (id,))
    inscriptions = cur.fetchall()

    cur.close()
    db.close()
    return render_template('pilotes/detail.html', pilote=pilote, inscriptions=inscriptions)


# ── 7. Recherche par mot-clé ─────────────────────────────────────────────────

@app.route('/pilotes/recherche')
def pilotes_search():
    """Recherche de pilotes par mot-clé (nom, prénom ou email)."""
    q = request.args.get('q', '').strip()
    pilotes = []

    if q:
        db = get_db()
        cur = db.cursor(dictionary=True)
        like = f'%{q}%'
        cur.execute("""
            SELECT id_pilote, nom_pilote, prenom_pilote, date_naissance, niveau, email
            FROM PILOTE
            WHERE nom_pilote LIKE %s
               OR prenom_pilote LIKE %s
               OR email LIKE %s
            ORDER BY nom_pilote ASC
        """, (like, like, like))
        pilotes = cur.fetchall()
        cur.close()
        db.close()

    return render_template('pilotes/search.html', pilotes=pilotes, query=q)


# ── 3. Recherche par critère (niveau) ────────────────────────────────────────

@app.route('/pilotes/filtre')
def pilotes_filter():
    """Filtre les pilotes par niveau."""
    niveau = request.args.get('niveau', '')
    db = get_db()
    cur = db.cursor(dictionary=True)

    if niveau:
        cur.execute("""
            SELECT id_pilote, nom_pilote, prenom_pilote, date_naissance, niveau, email
            FROM PILOTE WHERE niveau = %s
            ORDER BY nom_pilote ASC
        """, (niveau,))
    else:
        cur.execute("""
            SELECT id_pilote, nom_pilote, prenom_pilote, date_naissance, niveau, email
            FROM PILOTE ORDER BY nom_pilote ASC
        """)

    pilotes = cur.fetchall()
    cur.close()
    db.close()
    return render_template('pilotes/list.html', pilotes=pilotes, niveau_filtre=niveau)


# ══════════════════════════════════════════════════════════════════════════════
#  6. STATISTIQUES / CLASSEMENT
# ══════════════════════════════════════════════════════════════════════════════

@app.route('/stats')
def stats():
    """Statistiques globales et classement des pilotes."""
    db = get_db()
    cur = db.cursor(dictionary=True)

    # classement des pilotes par nombre d'inscriptions
    cur.execute("""
        SELECT p.id_pilote, p.nom_pilote, p.prenom_pilote,
               COUNT(i.id_stage) AS nb_inscriptions,
               RANK() OVER (ORDER BY COUNT(i.id_stage) DESC) AS classement
        FROM PILOTE p
        LEFT JOIN INSCRIPTION i ON p.id_pilote = i.id_pilote
        GROUP BY p.id_pilote, p.nom_pilote, p.prenom_pilote
        ORDER BY nb_inscriptions DESC, p.nom_pilote ASC
    """)
    classement = cur.fetchall()

    # répartition par niveau
    cur.execute("""
        SELECT niveau, COUNT(*) AS nb
        FROM PILOTE
        GROUP BY niveau
        ORDER BY nb DESC
    """)
    repartition = cur.fetchall()

    # nombre d'inscriptions par circuit
    cur.execute("""
        SELECT c.nom_circuit, COUNT(i.id_pilote) AS nb_inscriptions
        FROM CIRCUIT c
        LEFT JOIN STAGE s ON c.id_circuit = s.id_circuit
        LEFT JOIN INSCRIPTION i ON s.id_stage = i.id_stage
        GROUP BY c.id_circuit, c.nom_circuit
        ORDER BY nb_inscriptions DESC
    """)
    inscriptions_circuit = cur.fetchall()

    cur.close()
    db.close()
    return render_template('stats.html',
                           classement=classement,
                           repartition=repartition,
                           inscriptions_circuit=inscriptions_circuit)


# ── LANCEMENT ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    app.run(debug=True, port=5000)
