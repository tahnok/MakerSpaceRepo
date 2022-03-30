import { Calendar } from '@fullcalendar/core';
import '@fullcalendar/common/main.css'
import interactionPlugin from '@fullcalendar/interaction';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';

let calendarEl = document.getElementById('calendar');
const urlParams = new URLSearchParams(window.location.search);
const space_id = urlParams.get('space_id')

let calendar = new Calendar(calendarEl, {
    plugins: [interactionPlugin, timeGridPlugin, listPlugin],
    headerToolbar: {
        left: 'prev,today,next',
        center: '',
        right: 'timeGridWeek,timeGridDay'
    },
    views: {
        timeGridWeek: {
            dayHeaderFormat: {
                weekday: 'long',
            },
        },
    },
    allDaySlot: false,
    timeZone: 'America/New_York',
    initialView: 'timeGridWeek',
    navLinks: true,
    slotEventOverlap: false,
    slotMinTime: "07:00:00",
    slotMaxTime: "22:00:00",
    eventTimeFormat: {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
    },
    dayMaxEvents: true,
    eventClick: function (info) {
        alert('Event: ' + info.event.title);
    },
    eventSources: [
        {
            url: `/admin/shifts/get_availabilities?space_id=${space_id}`,
        }
    ],
});

calendar.render();
