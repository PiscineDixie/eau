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
    var selTdElem = $(this).parent("td.heure");
    // Find the next value field. Its up one element, down to next
    var valTdElem = selTdElem.next("td.valeur");
    var lecture = valTdElem.children("input.mesureVal").first().val();
    // Si pas de lecture, on modifie la valeur du selecteur
    if (!lecture)
      $(this).val(heure);
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
  // Activer le datepicker si présent (lors de l'édition d'une journée)
  $("input.datepicker").datepicker({
    maxDate: "0D",
     dateFormat: "yy-mm-dd",
     beforeShowDay: filterExisting
   });
     
  $("select.heureVar").on("change", updateAutresHeuresEH);
});
