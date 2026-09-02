function openModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.style.display = "flex";
}

function closeModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.style.display = "none";
}

window.onclick = function (event) {
  if (event.target.classList.contains("modal")) {
    event.target.style.display = "none";
  }
};

function error(input, message) {
  if (!input) return false;
  input.classList.remove("input-success");
  input.classList.add("input-error");

  const e = document.getElementById(input.id + "Error");
  if (e) {
    e.textContent = message;
    e.style.display = "block";
  }

  return false;
}

function success(input) {
  if (!input) return true;
  input.classList.remove("input-error");
  input.classList.add("input-success");

  const e = document.getElementById(input.id + "Error");
  if (e) {
    e.textContent = "";
    e.style.display = "none";
  }

  return true;
}

function validateName(input) {
  if (!input || input.value.trim() === "") {
    return error(input, "Name cannot be blank.");
  }
  return success(input);
}

function validateEmail(input) {
  if (!input || input.value.trim() === "") {
    return error(input, "Email ID cannot be blank.");
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input.value.trim())) {
    return error(input, "Enter a valid email ID.");
  }

  return success(input);
}

function validatePassword(input) {
  if (!input || input.value === "") {
    return error(input, "Password cannot be blank.");
  }
  return success(input);
}

function validateConfirmPassword(input) {
  const passInput = document.getElementById("signupPassword");
  const password = passInput ? passInput.value : "";

  if (!input || input.value === "") {
    return error(input, "Confirm password cannot be blank.");
  }

  if (input.value !== password) {
    return error(input, "Passwords do not match.");
  }

  return success(input);
}

function validatePhone(input) {
  if (!input) return false;
  input.value = input.value.replace(/[^0-9]/g, "");

  if (input.value === "") {
    return error(input, "Mobile number cannot be blank.");
  }

  if (input.value.length !== 10) {
    return error(input, "Mobile number must be exactly 10 digits.");
  }

  return success(input);
}

function validateBlank(input, fieldName = "This field") {
  if (!input || input.value.trim() === "") {
    return error(input, fieldName + " cannot be blank.");
  }
  return success(input);
}

// Event Listeners - Signup Form
const signupName = document.getElementById("signupName");
if (signupName) {
  signupName.addEventListener("input", function () {
    validateName(this);
  });
}

const signupEmail = document.getElementById("signupEmail");
if (signupEmail) {
  signupEmail.addEventListener("input", function () {
    validateEmail(this);
  });
}

const signupPassword = document.getElementById("signupPassword");
if (signupPassword) {
  signupPassword.addEventListener("input", function () {
    validatePassword(this);

    const confirm = document.getElementById("confirmPassword");
    if (confirm && confirm.value !== "") {
      validateConfirmPassword(confirm);
    }
  });
}

const confirmPassword = document.getElementById("confirmPassword");
if (confirmPassword) {
  confirmPassword.addEventListener("input", function () {
    validateConfirmPassword(this);
  });
}

const signupPhone = document.getElementById("signupPhone");
if (signupPhone) {
  signupPhone.addEventListener("input", function () {
    validatePhone(this);
  });
}

const signupAddress = document.getElementById("signupAddress");
if (signupAddress) {
  signupAddress.addEventListener("input", function () {
    validateBlank(this, "Address");
  });
}

const signupGender = document.getElementById("signupGender");
if (signupGender) {
  signupGender.addEventListener("change", function () {
    if (this.value === "") {
      error(this, "Please select your gender.");
    } else {
      success(this);
    }
  });
}

// Registration Form Submit Handler
const signupForm = document.getElementById("signupForm");
if (signupForm) {
  signupForm.addEventListener("submit", function (event) {
    event.preventDefault();

    const name = document.getElementById("signupName");
    const email = document.getElementById("signupEmail");
    const password = document.getElementById("signupPassword");
    const confirm = document.getElementById("confirmPassword");
    const phone = document.getElementById("signupPhone");
    const address = document.getElementById("signupAddress");
    const gender = document.getElementById("signupGender");

    validateName(name);
    validateEmail(email);
    validatePassword(password);
    validateConfirmPassword(confirm);
    validatePhone(phone);
    validateBlank(address, "Address");

    if (gender && gender.value === "") {
      error(gender, "Please select your gender.");
    } else {
      success(gender);
    }

    const firstError = this.querySelector(".input-error");

    if (firstError) {
      firstError.focus();
      return;
    }

    this.submit();
  });
}

// Event Listeners & Submit Handler - Login Form
const loginEmail = document.getElementById("loginEmail");
if (loginEmail) {
  loginEmail.addEventListener("input", function () {
    validateEmail(this);
  });
}

const loginPassword = document.getElementById("loginPassword");
if (loginPassword) {
  loginPassword.addEventListener("input", function () {
    validateBlank(this, "Password");
  });
}

const loginForm = document.getElementById("loginForm");
if (loginForm) {
  loginForm.addEventListener("submit", function (event) {
    event.preventDefault();

    const email = document.getElementById("loginEmail");
    const password = document.getElementById("loginPassword");

    validateEmail(email);
    validateBlank(password, "Password");

    const firstError = this.querySelector(".input-error");

    if (firstError) {
      firstError.focus();
      return;
    }

    this.submit();
  });
}

// Keyboard Navigation for Signup Form
if (signupForm) {
  const fields = Array.from(
    signupForm.querySelectorAll("input, select, textarea")
  );

  fields.forEach(function (field, index) {
    field.addEventListener("keydown", function (event) {
      if (event.key === "Enter" && field.tagName !== "TEXTAREA") {
        event.preventDefault();

        if (field.classList.contains("input-error")) {
          field.focus();
          return;
        }

        if (index < fields.length - 1) {
          fields[index + 1].focus();
        }
      }
    });
  });
}