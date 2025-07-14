document.addEventListener("DOMContentLoaded", function () {
	const camposDate = document.getElementsByClassName("campo-data");
	Array.from(camposDate).forEach(campo => {
		function atualizarPlaceholderColor() {
			campo.style.color = campo.value ? '#000000' : "var(--grey)";
		}
		atualizarPlaceholderColor();
		campo.addEventListener("input", atualizarPlaceholderColor);
    });

    function alterarCorSelect() {
        var selects = document.querySelectorAll('.custom-select');
        selects.forEach(function (select) {
            if (select.value !== '') {
                select.style.color = '#000';
            } else {
                select.style.color = '#aaa';
            }
        });
    }
    window.addEventListener('load', alterarCorSelect);
    document.querySelectorAll('.custom-select').forEach(function (select) {
        select.addEventListener('change', alterarCorSelect);
    });
});
