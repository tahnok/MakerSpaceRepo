import { Calendar } from "@fullcalendar/core";
import "@fullcalendar/common/main.css";
import interactionPlugin from "@fullcalendar/interaction";
import timeGridPlugin from "@fullcalendar/timegrid";
import listPlugin from "@fullcalendar/list";
import googleCalendarPlugin from "@fullcalendar/google-calendar";
import Turbolinks from "turbolinks";
import iCalendarPlugin from "@fullcalendar/icalendar";

// Modal
const shiftModal = new bootstrap.Modal(document.getElementById("shiftModal"));

// Show
let sourceShow = {
  google: document.getElementById("hide-show-google-events").checked
    ? "block"
    : "none",
  transparent: document.getElementById("hide-show-unavailabilities").checked
    ? "block"
    : "none",
  staffNeeded: document.getElementById("hide-show-staff-needed").checked
    ? "block"
    : "none",
};
let hiddenIds = {};

// Inputs
const startDateTimeInput = document.getElementById("start-datetime");
const endDateTimeInput = document.getElementById("end-datetime");
const userIdInput = document.getElementById("user-id");
const reasonInput = document.getElementById("reason");
const modalSave = document.getElementById("modal-save");

const modalDelete = document.getElementById("modal-delete");
const modalClose = document.getElementById("modal-close");
modalClose.addEventListener("click", () => {
  if (modalDelete.classList.contains("d-block")) {
    modalDelete.classList.remove("d-block");
    modalDelete.classList.add("d-none");
  }
});

modalSave.addEventListener("click", () => {
  createCalendarEvent();
});

modalDelete.addEventListener("click", () => {
  removeEvent(document.getElementById("shift-id").value, null);
});

const startPicker = startDateTimeInput.flatpickr({
  enableTime: true,
  time_24hr: true,
  altInput: true,
  altFormat: "F j, Y at H:i",
  onChange: (selectedDates, dateStr, instance) => {
    populateUsers({
      start: new Date(
        Date.parse(selectedDates[0]) -
          new Date().getTimezoneOffset() * 60 * 1000
      ),
      end: new Date(
        Date.parse(endPicker.selectedDates[0]) -
          new Date().getTimezoneOffset() * 60 * 1000
      ),
    });
  },
});

const endPicker = endDateTimeInput.flatpickr({
  enableTime: true,
  time_24hr: true,
  altInput: true,
  altFormat: "F j, Y at H:i",
  onChange: (selectedDates, dateStr, instance) => {
    populateUsers({
      end: new Date(
        Date.parse(selectedDates[0]) -
          new Date().getTimezoneOffset() * 60 * 1000
      ),
      start: new Date(
        Date.parse(startPicker.selectedDates[0]) -
          new Date().getTimezoneOffset() * 60 * 1000
      ),
    });
  },
});

const newShiftUserSelect = new TomSelect("#user-id", {
  maxItems: 3,
  placeholder: "Select users",
  search: true,
  plugins: ["remove_button"],
});

// Calendar Config
const calendarEl = document.getElementById("calendar");

let calendar;

fetch("/admin/shifts/get_external_staff_needed", {
  method: "GET",
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json",
  },
})
  .then((res) => res.json())
  .then((res) => {
    calendar = new Calendar(calendarEl, {
      firstDay: 1, // Needs to play nice with Rails.
      plugins: [
        interactionPlugin,
        timeGridPlugin,
        listPlugin,
        googleCalendarPlugin,
        iCalendarPlugin,
      ],
      customButtons: {
        addNewEvent: {
          text: "+",
          click: () => {
            openModal();
          },
        },
      },
      headerToolbar: {
        left: "prev,today,next",
        center: "",
        right: "addNewEvent,timeGridWeek,timeGridDay",
      },
      contentHeight: "auto",
      slotEventOverlap: false,
      allDaySlot: false,
      timeZone: "America/New_York",
      initialView: "timeGridWeek",
      navLinks: true,
      selectable: true,
      selectMirror: true,
      slotMinTime: "07:00:00",
      slotMaxTime: "22:00:00",
      eventTimeFormat: {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
      },
      editable: true,
      dayMaxEvents: true,
      eventSources: [
        {
          id: "transparent",
          url: "/admin/shifts/get_availabilities?transparent=true",
          editable: false,
        },
        {
          id: "shifts",
          url: "/admin/shifts/get_shifts",
        },
        {
          id: "google",
          googleCalendarApiKey: "AIzaSyCMNxnP0pdKHtZaPBJAtfv68A2h6qUeuW0",
          googleCalendarId:
            "c_d7liojb08eadntvnbfa5na9j98@group.calendar.google.com",
          color: "rgba(255,31,31,0.4)",
          editable: false,
        },
        {
          id: "staffNeeded",
          url: "/admin/shifts/get_staff_needed",
          color: "rgba(40,40,40,0.4)",
          editable: false,
        },
        ...res.map((cal) => {
          return {
            id: "staffNeeded",
            color: cal.color,
            editable: false,
            ...(cal.calendar_url.includes(".ics")
              ? {
                  format: "ics",
                  url: `/admin/shifts/ics?staff_needed_calendar_id=${cal.id}`,
                }
              : {
                  googleCalendarApiKey:
                    "AIzaSyCMNxnP0pdKHtZaPBJAtfv68A2h6qUeuW0",
                  googleCalendarId: cal.calendar_url,
                }),
          };
        }),
      ],
      select: (arg) => {
        openModal(arg);
      },
      eventClick: (arg) => {
        if (arg.event.source.id === "shifts") {
          editShift(arg);
        } else if (arg.event.source.id === "staffNeeded") {
          staffNeededEvent(arg);
        }
      },
      eventDrop: (arg) => {
        modifyEvent(arg);
      },
      eventResize: (arg) => {
        modifyEvent(arg);
      },
      eventOrder: (a, b) => {
        if (
          (a.title.includes("is unavailable") &&
            b.title.includes("is unavailable")) ||
          (!a.title.includes("is unavailable") &&
            !b.title.includes("is unavailable"))
        ) {
          return 0;
        } else if (a.title.includes("is unavailable")) {
          return -1;
        } else {
          return 1;
        }
      },
      eventSourceSuccess: (content, xhr) => {
        content.forEach((event) => {
          if (hiddenIds[event.userId] === "none") {
            event.display = "none";
          } else if (hiddenIds[event.userId] === "block") {
            event.display = "block";
          } else {
          }
        });
        hideShowEvents("check");
        return content;
      },
      loading: (stillLoading) => {
        if (!stillLoading) {
          refreshColours();
        }
      },
    });
    calendar.render();
  });

const refreshColours = () => {
  document
    .querySelectorAll(".fc-prev-button, .fc-next-button, .fc-today-button")
    .forEach((btn) => {
      btn.addEventListener("click", () => {
        fetch(
          "/admin/shifts/refresh_hours?format=js&date=" +
            calendar.getDate().toISOString(),
          {
            method: "GET",
          }
        )
          .then((r) => r.text())
          .then((html) => {
            const userColoursFrag = document
              .createRange()
              .createContextualFragment(html);
            document
              .getElementById("user-colours-partial")
              .replaceChildren(userColoursFrag);
          });
      });
    });
};
// Refresh pending Shifts
const refreshPendingShifts = () => {
  fetch("/admin/shifts/pending_shifts?format=js", {
    method: "GET",
  })
    .then((r) => r.text())
    .then((html) => {
      const fragment = document.createRange().createContextualFragment(html);
      document
        .getElementById("pending-shift-partial")
        .replaceChildren(fragment);
    });
};

const populateUsers = (arg) => {
  return new Promise((resolve, reject) => {
    let currentUser = null || userIdInput.value;
    userIdInput.tomselect.clear();
    userIdInput.tomselect.clearOptions();
    let startDate, endDate;
    if (arg.event) {
      startDate = arg.event.start;
      endDate = arg.event.end;
    } else {
      startDate = arg.start;
      endDate = arg.end;
    }
    let startHour = startDate.toUTCString().split(" ")[4].split(":")[0];
    let startMinute = startDate.toUTCString().split(" ")[4].split(":")[1];
    let endHour = endDate.toUTCString().split(" ")[4].split(":")[0];
    let endMinute = endDate.toUTCString().split(" ")[4].split(":")[1];
    let weekDayInt = {
      "Sun,": 0,
      "Mon,": 1,
      "Tue,": 2,
      "Wed,": 3,
      "Thu,": 4,
      "Fri,": 5,
      "Sat,": 6,
    }[startDate.toUTCString().split(" ")[0]];
    fetch(
      `/admin/shifts/shift_suggestions?start=${startHour}:${startMinute}&end=${endHour}:${endMinute}&day=${weekDayInt}`,
      {
        method: "GET",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      }
    )
      .then((res) => res.json())
      .then((res) => {
        res.forEach((user) => {
          userIdInput.tomselect.addOption({
            value: user.id,
            text: `${user.name} ${user.acceptable ? "" : "(unavailable)"}`,
          });
        });
        resolve();
        userIdInput.tomselect.setValue(currentUser);
      })
      .catch((err) => {
        reject(err);
      });
  });
};

// Calendar CRUD
const createCalendarEvent = () => {
  let selected_users = [];
  for (let option of userIdInput.options) {
    if (option.selected) {
      selected_users.push(option.value);
    }
  }
  fetch("/admin/shifts", {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      start_datetime: startDateTimeInput.value,
      end_datetime: endDateTimeInput.value,
      format: "json",
      user_id: selected_users,
      reason: reasonInput.value,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      calendar.addEvent(
        {
          title: data.name,
          start: data.start,
          end: data.end,
          allDay: false,
          id: data["id"],
          color: data.color,
          className: data.className,
        },
        "shifts"
      );
      shiftModal.hide();
      calendar.unselect();
      refreshPendingShifts();
      if (modalDelete.classList.contains("d-block")) {
        removeEvent(document.getElementById("shift-id").value, true);
      }
    })
    .catch((error) => {
      console.log("An error occurred: " + error.message);
    });
};

const openModal = (arg) => {
  if (!arg) {
    arg = { start: new Date(), end: new Date() };
  }
  if (arg !== undefined && arg !== null) {
    startPicker.setDate(Date.parse(arg.startStr));
    endPicker.setDate(Date.parse(arg.endStr));
  }
  if (arg.event) {
    if (arg.event.source.id === "shifts") {
      document.getElementById("shift-id").value = arg.event.id;
    }
  }
  populateUsers(arg).then(() => {
    shiftModal.show();
  });
};
const modifyEvent = (arg) => {
  let adjustedStart = new Date(
    Date.parse(arg.event.start) + new Date().getTimezoneOffset() * 60000
  );
  let adjustedEnd = new Date(
    Date.parse(arg.event.end) + new Date().getTimezoneOffset() * 60000
  );
  startPicker.setDate(Date.parse(arg.event.end));
  endPicker.setDate(Date.parse(arg.event.end));
  fetch("/admin/shifts/" + arg.event.id, {
    method: "PUT",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      start_datetime: adjustedStart,
      end_datetime: adjustedEnd,
      format: "json",
    }),
  })
    .then((response) => {
      if (!response.ok) {
        arg.revert();
      }
      refreshPendingShifts();
    })
    .catch((error) => {
      console.log("An error occurred: " + error.message);
    });
};
const removeEvent = (shift_id, bypass = false) => {
  let confirmation = bypass
    ? true
    : confirm("Are you sure you want to delete this shift?");
  if (confirmation) {
    fetch("/admin/shifts/" + shift_id, {
      method: "DELETE",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ format: "json" }),
    })
      .then((response) => {
        if (response.ok) {
          calendar.refetchEvents();
          refreshPendingShifts();
          shiftModal.hide();
          document.getElementById("shift-id").value = "";
          modalDelete.classList.remove("d-block");
          modalDelete.classList.add("d-none");
        } else {
          console.log("An error occurred");
        }
        refreshPendingShifts();
      })
      .catch((error) => {
        console.log("An error occurred: " + error.message);
      });
  }
};

const editShift = (arg) => {
  document.getElementById("shift-id").value = arg.event.id;
  modalDelete.classList.remove("d-none");
  modalDelete.classList.add("d-block");
  fetch("/admin/shifts/get_shift?id=" + arg.event.id, {
    method: "GET",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  })
    .then((response) => response.json())
    .then((data) => {
      startPicker.setDate(Date.parse(data.start_datetime));
      endPicker.setDate(Date.parse(data.end_datetime));
      reasonInput.value = data.reason;
      populateUsers({
        start: new Date(
          Date.parse(data.start_datetime) +
            new Date().getTimezoneOffset() * 60 * 1000
        ),
        end: new Date(
          Date.parse(data.end_datetime) +
            new Date().getTimezoneOffset() * 60 * 1000
        ),
      }).then(() => {
        data.users.forEach((user) => {
          userIdInput.tomselect.addItem(user.id);
        });
      });
      shiftModal.show();
    });
};

const staffNeededEvent = (arg) => {
  openModal(arg);
  startPicker.setDate(
    Date.parse(arg.event.start) + new Date().getTimezoneOffset() * 60 * 1000
  );
  endPicker.setDate(
    Date.parse(arg.event.end) + new Date().getTimezoneOffset() * 60 * 1000
  );
};

// Hide/Show Events
const hideShowEvents = (eventName) => {
  if (eventName !== "check") {
    if (sourceShow[eventName] === "none") {
      sourceShow[eventName] = "block";
    } else {
      sourceShow[eventName] = "none";
    }
  }
  let allEvents = calendar.getEvents();
  for (let ev of allEvents) {
    if (eventName === "check") {
      let display = sourceShow.hasOwnProperty(ev.source.id)
        ? sourceShow[ev.source.id]
        : "block";
      ev.setProp("display", display);
      if (ev.extendedProps.userId) {
        ev.setProp(
          "display",
          hiddenIds[ev.extendedProps.userId] === "none" ? "none" : display
        );
      }
    } else if (ev.source.id === eventName) {
      ev.setProp("display", sourceShow[eventName]);
      if (ev.extendedProps.userId) {
        ev.setProp(
          "display",
          hiddenIds[ev.extendedProps.userId] === "none"
            ? "none"
            : sourceShow[eventName]
        );
      }
    }
  }
  if (eventName === "transparent") {
    [...document.getElementsByClassName("shift-hide-button")].forEach((el) => {
      let userId = el.id.substring(5);
      el.checked =
        hiddenIds[userId] === "none"
          ? false
          : sourceShow["transparent"] === "block";
    });
  }
};

document
  .getElementById("hide-show-unavailabilities")
  .addEventListener("click", () => {
    hideShowEvents("transparent");
  });

document
  .getElementById("hide-show-google-events")
  .addEventListener("click", () => {
    hideShowEvents("google");
  });

document
  .getElementById("hide-show-staff-needed")
  .addEventListener("click", () => {
    hideShowEvents("staffNeeded");
  });

// Toggle Staff Visibility
window.toggleVisibility = (id) => {
  let allEvents = calendar.getEvents();
  for (let ev of allEvents) {
    if (ev.extendedProps.userId === id) {
      ev.setProp(
        "display",
        document.getElementById(`user-${id}`).checked ? "block" : "none"
      );
      hiddenIds[id] = document.getElementById(`user-${id}`).checked
        ? "block"
        : "none";
    }
  }
};

// Update the staff's color
window.updateColor = (userId, color) => {
  fetch("/admin/shifts/update_color", {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      user_id: userId,
      color: color,
      format: "json",
    }),
  })
    .then((response) => {
      if (response.ok) {
        Turbolinks.visit(window.location, { action: "replace" });
      } else {
        const toast = new bootstrap.Toast(
          document.getElementById("toast-color-update-failed")
        );
        toast.show();
      }
    })
    .catch((error) => {
      const toast = new bootstrap.Toast(
        document.getElementById("toast-color-update-failed")
      );
      toast.show();
      console.log("An error occurred: " + error.message);
    });
};
