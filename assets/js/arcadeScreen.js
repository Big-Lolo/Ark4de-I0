
function setup(htmlComponent) {

    const buttonArcade = document.getElementById("start-button");
    const pag1 = document.getElementById("PAG1"); //Pantalla inicial (pantalla de benvinguda)
    const pag2 = document.getElementById("PAG2"); //Pantalla scoreboard + regles + nom jugador
    const pag3 = document.getElementById("PAG3"); //Pagina de joc (pantalla de joc)
    const pag4 = document.getElementById("PAG4"); //Pagina de finalitzar joc (pantalla de Game Over) + resultats finals
    let buttonPlay //Esto se tendria que obtener cuando cargue la pantalla que tiene el boton de Play con el scoreboard (mover despues)
    const persiana = document.getElementById("persiana"); //Persiana que baja al finalizar el juego (pantalla 3 => 4)
    const restartButton = document.getElementById("restart-button"); //Boton de reiniciar el juego (pantalla 4)

    var playing = false;
    let playerNameElement
    let playerName = ""
    let scoreboard = []
    let finalResults = [] //Array que contendra el ranking final del jugador (pantalla 4)

    htmlComponent.addEventListener("Scoreboard", function (event) {
        //Recibimos el evento de matlab con el scoreboard
        const scoreboardData = event.Data;
        //Ahora actualizamos variable del scoreboard que estara esperando el elemento que cargara dicho SCB
        scoreboard = scoreboardData;
    });

    htmlComponent.addEventListener("FinalResults", function (event) {
        //Recibimos el evento de matlab con el scoreboard
        const finalResultsData = event.Data;
        //Ahora actualizamos variable del scoreboard que estara esperando el elemento que cargara dicho SCB
        finalResults = JSON.parse(finalResultsData);
    });




    buttonArcade.addEventListener("click", async function () {
        //Al premer, mostrar next screen (La next screen mostrara un scoreboard dels jugadors i un lloc per a ficar el nom)
        //També mostrarà els punts dels jugadors i a un costat, mostrara els punts de cada item que s'agafi.
        transitionScreen('PAG2');
        htmlComponent.sendEventToMATLAB("ButtonClicked", 2);

    });

    window.addEventListener("keydown", function (event) {
        if (playing) {
            const keyCode = event.keyCode;
            htmlComponent.sendEventToMATLAB("keyPressed", keyCode);
        }
    });

    function transitionScreen(screenName) {
        //Funcio per a transitar entre pantalles (pantalla 1, 2, 3 i 4)
        pag1.style.display = "none";
        pag2.style.display = "none";
        pag3.style.display = "none";
        pag4.style.display = "none";

        switch (screenName) {
            case 'PAG1':
                pag1.style.display = "flex";
                break;
            case 'PAG2':
                pag2.style.display = "flex";
                htmlComponent.sendEventToMATLAB("getScoreboard", "");
                showScoreboard();
                break;
            case 'PAG3':
                htmlComponent.sendEventToMATLAB("startTime", "");
                pag3.style.display = "flex";
                playing = true;
                break;
            case 'PAG4':
                pag4.style.display = "flex";
                break;
            default:
                console.error("Pantalla no reconeguda: ", screenName);
        }

    }


    function showScoreboard() {
        buttonPlay = document.getElementById("play-button"); //Obtenim el botó de Play quan es carrega la pantalla 2 (scoreboard)
        playerNameElement = document.getElementById("player-name"); //Obtenim el input del nom del jugador quan es carrega la pantalla 2 (scoreboard)
        let players = [];

        const waitForScoreboard = setInterval(() => {
            if (scoreboard.length > 0) {
                clearInterval(waitForScoreboard);
                console.log("Scoreboard received:", scoreboard);
                // Update the players array with the received scoreboard data
                players = [...scoreboard];
                players.sort((a, b) => b.score - a.score);

                // Populate the scoreboard UI immediately after receiving data
                const scoreboardBody = document.getElementById("scoreboard-body");
                scoreboardBody.innerHTML = players.map((player, index) => `
                <div class="border flex flex-row w-full">
                <h2 class="ml-2"> #${index + 1} </h2>
                <div class="flex flex-row justify-between items-center px-36 w-full">
                    <p class="px-4 py-2">${player.name}</p>
                    <p class="px-10 py-2">${(player.score).toLocaleString("es-ES")}</p>
                </div>
                </div>
            `).join('');
            }
        }, 100); // Check every 100ms

        //Agregamos evento al boton del play
        buttonPlay.addEventListener("click", function () {
            //Pasar a pantalla de juego + enviar señal de iniciar juego a matlab + enviar nom jugador a matlab
            console.log("Iniciando juego...");

            playerName = playerNameElement.value;
            htmlComponent.sendEventToMATLAB("userName", String(playerName));

            //Transicionar a la pantalla de juego (pantalla 3)
            transitionScreen('PAG3');
            //Emviar señal de iniciar juego + nombre a matlab
            showClock();

        });

    };

    showScoreboard();

    function showClock() {
        const clock = document.getElementById("clockBox");
        if (!clock) {
            console.error("Element with id 'clockBox' not found in the DOM.");
            return;
        }
        const maxTime = 3; // 2 minutes
        let timeLeft = maxTime * 60; // Convert to seconds
        const interval = setInterval(() => {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            clock.innerHTML = `<p class="text-9xl play-bold justify-center items-center shadow-lg">${minutes}:${seconds < 10 ? '0' : ''}${seconds}</p>`;
            timeLeft--;
            if (timeLeft <= maxTime * 30) {
                clock.style.color = "yellow";
            }
            if (timeLeft < 20) {
                clock.style.color = "red";
            } else if (timeLeft > maxTime * 30) {
                clock.style.color = "black";
            }
            if (timeLeft < 0) {
                clearInterval(interval);
                // Falta ficar logica de pasar a la pantalla de Game Over (pantalla 4)
                clock.innerHTML = `<p class="text-9xl play-bold justify-center items-center shadow-lg">0:00</p>`;
                // Send data a matlab de deshabilitar control.

                //Wait de 2 segons per a que el jugador vegi que ha acabat el temps i després canviar de pantalla.
                setTimeout(() => {
                    // Aquí puedes cambiar a la pantalla de Game Over
                    transitionOver()
                }, 2000);

            }
        }, 1000);
    }



    async function transitionOver() {
        //Bajar la persiana con una animacion de 1 segundo, rápidamente.
        //Ocultamos la PAG3 y mostramos la PAG4
        //Cambiamos la opacidad de los elementos internos de la PAG4 de 0 a 1 para mostrar suavemente el game over ( 0.5 segundos)

        persiana.style.transition = "transform 1s ease-in-out";
        persiana.style.transform = "translateY(0)";
        //TODO: Estaria GENIAL implementar sonido de persiana mientras baja.
        htmlComponent.sendEventToMATLAB("endTime", "");
        setTimeout(() => {
            transitionScreen('PAG4'); // Cambiamos a la pantalla de Game Over
        }, 1000); // Wait for the persiana animation to complete

        const container4 = document.querySelector(".container4");
        if (container4) {
            container4.style.opacity = "0";
            container4.style.transition = "opacity 1s ease-in-out";

            setTimeout(() => {
                container4.style.opacity = "1";
            }, 2000); // 50ms suele ser suficiente para la mayoría de los navegadores
        }

        //Wait hasta que tengamos el score final del jugador y el ranking.

        while (finalResults.length == 0) {
            // Esperar hasta que el scoreboard tenga datos
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        htmlComponent.sendEventToMATLAB("", "");
        let endResumen = document.getElementById("endResumen");
        if (endResumen) {
            endResumen.innerHTML = `
                <div class="border-gray-300 rounded-lg text-white px-72 py-2 bg-[#db5cdb] flex flex-row justify-between w-full">
                    <h2 class="">Player</h2>
                    <p id="nameText">`+ finalResults.userName + `</p>
                </div>
                <div class="border-gray-300 rounded-lg text-white px-72 py-2 bg-[#db5cdb] flex flex-row justify-between w-full">
                    <h2 class="">Score</h2>
                    <p id="scoreText">`+ finalResults.score + `</p>
                </div>
                <div class="border-gray-300 rounded-lg text-white px-72 py-2 bg-[#db5cdb] flex flex-row justify-between w-full">
                    <h2 class="">Position</h2>
                    <p id="positionText">`+ finalResults.position + `</p>
                </div>
            `;
        }
    }

    const soundToggle = document.getElementById("soundToggle");
    var checked = true;
    soundToggle.addEventListener("click", function () {
        if (checked) {
            htmlComponent.sendEventToMATLAB("soundOn", "");
            soundToggle.textContent = "🔊";
            checked = false;
        } else {
            htmlComponent.sendEventToMATLAB("soundOff", "");
            soundToggle.textContent = "🔇";
            checked = true;
        }
    });



}


