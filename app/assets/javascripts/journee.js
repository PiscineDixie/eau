/*
 * Javascript pour l'entrée de données pour une journée
 */

/*
 * Fonction pour accélérer l'entrée de données en propageant
 * automatiquement l'heure d'un indicateur à l'autre.
 * On traverse les inputs et modifie l'heure pour mettre la même que celle sélectionnée
 * lorsque la donnée de lecture est encore vide.
 */

function updateAutresHeuresEH(event) {
  // Lire la valeur de l'heure qui vient d'être sélectionnée
  var heure = $(this).val();
  
  // Modifier tous les autres qui n'ont pas encore de valeurs de lecture
  $("select.heureVar").each(function(idx) {
    var $sel = $(this);
    var lblE = $sel.parent(".heure");
    // Find the next value field. Its up one element, down to next
    var inpVal = lblE.next(".mesureVal");
    var lecture = inpVal.val();
    // Si pas de lecture, on modifie la valeur du selecteur
    if (!lecture)
      $sel.val(heure);
  });
}


/* La page web pour ajouter une journée ajoute une variable window.jourCompletes
 * Si la date est presente dans cette array, on indique a datepicker de ne pas permettre
 * sa selection.
 */
function filterExisting(date) {
  var s = $.datepicker.formatDate( "yy-mm-dd", date);
  if (window.jourCompletes && window.jourCompletes.indexOf(s) != -1)
    return [false, ""];
  return [true, ""];
}

$(document).ready(function() {
  $("select.heureVar").on("change", updateAutresHeuresEH);
});
