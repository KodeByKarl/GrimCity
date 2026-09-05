$(() => {
    window.addEventListener('message', function (event) {
        const data = event.data;

        // === OLD IMAGE/PRINTER SYSTEM ===
        if (data.action === 'show') {
            $('#image').attr('src', data.image_url);
            $('#document-title').text(data.title || 'Untitled Document');  // New: Set the document title
            $('body').fadeIn('slow');
            $.post('https://nl-university/setUIFocus');
        }

        if (data.action === 'hide') {
            $('body').fadeOut('slow');
            $.post('https://nl-university/unsetUIFocus');
        }

        if (data.action === 'playSound' && data.sound === 'printer') {
            const printer = document.getElementById('printer-audio');
            if (printer) {
                const volume = data.volume !== undefined ? data.volume : 1.0;
                printer.volume = volume;
                printer.currentTime = 0;
                printer.play();
            }
        }

        if (data.action === 'stopSound' && data.sound === 'printer') {
            const audio = document.getElementById('printer-audio');
            if (audio) {
                audio.pause();
                audio.currentTime = 0;
            }
        }

        // === QUIZ SYSTEM ===
        if (data.action === 'showQuiz') {
            $('#question-text').text(data.quiz.question);
            $('#question-ui').removeClass('hidden');
            $('body').fadeIn('fast');

            $('#quiz-options .quiz-btn').each(function () {
                const opt = $(this).data('option');
                $(this).text(`${opt}. ${data.quiz.options[opt]}`);
            });

            $('#quiz-options .quiz-btn').off('click').on('click', function () {
                const selected = $(this).data('option');
                $.post(`https://${GetParentResourceName()}/submitQuizAnswer`, JSON.stringify({
                    answer: selected,
                    correct: data.quiz.correct
                }));
                $('#question-ui').addClass('hidden');
                $('body').fadeOut('slow');
            });
        }

        // === BELL SYSTEM ===
        if (data.action === 'playSound' && data.sound === 'bell') {
            const bell = document.getElementById('bell-audio');
            if (bell) {
                bell.volume = data.volume !== undefined ? data.volume : 1.0;
                bell.currentTime = 0;
                bell.play();
            }
        }

        if (data.action === 'stopSound' && data.sound === 'bell') {
            const bell = document.getElementById('bell-audio');
            if (bell) {
                bell.pause();
                bell.currentTime = 0;
            }
        }
    });

    // ESC key closes UI
    document.onkeyup = function (event) {
        if (event.key === 'Escape') {
            $('body').fadeOut('slow');
            $.post('https://nl-university/unsetUIFocus');
        }
    };
});
