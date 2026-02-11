import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    loading: Boolean,
    expiresIn: { type: Number, default: 600 }
  }

  static targets = [
    "form",
    "email",
    "submitBtn",
    "spinner",
    "otpInput",
    "pinInput",
    "pinWrapper",
    "timer",
    "countdown",
    "resendBtn",
    "cooldown"
  ]

  connect() {
    if (this.hasTimerTarget) {
      this.startCountdown()
    }
  }

  disconnect() {
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval)
    }
    if (this.cooldownInterval) {
      clearInterval(this.cooldownInterval)
    }
  }

  // PIN input handling
  handlePinInput(event) {
    const input = event.target
    const value = input.value.replace(/\D/g, "")

    // Only allow single digit
    input.value = value.slice(0, 1)

    // Update hidden field with combined value
    this.updateOtpValue()

    // Move to next input if value entered
    if (value && input.nextElementSibling && input.nextElementSibling.classList.contains("pin-input")) {
      input.nextElementSibling.focus()
    }
  }

  handlePinKeydown(event) {
    const input = event.target

    // Handle backspace on empty input - move to previous
    if (event.key === "Backspace" && !input.value && input.previousElementSibling && input.previousElementSibling.classList.contains("pin-input")) {
      input.previousElementSibling.focus()
      event.preventDefault()
    }

    // Handle arrow keys
    if (event.key === "ArrowLeft" && input.previousElementSibling && input.previousElementSibling.classList.contains("pin-input")) {
      input.previousElementSibling.focus()
    }
    if (event.key === "ArrowRight" && input.nextElementSibling && input.nextElementSibling.classList.contains("pin-input")) {
      input.nextElementSibling.focus()
    }
  }

  handlePinPaste(event) {
    event.preventDefault()
    const paste = (event.clipboardData || window.clipboardData).getData("text")
    const digits = paste.replace(/\D/g, "").slice(0, 6)

    const inputs = this.pinInputTargets
    digits.split("").forEach((digit, index) => {
      if (inputs[index]) {
        inputs[index].value = digit
      }
    })

    // Focus the next empty input or the last one
    const nextEmptyIndex = Math.min(digits.length, inputs.length - 1)
    inputs[nextEmptyIndex].focus()

    this.updateOtpValue()
  }

  updateOtpValue() {
    const inputs = this.pinInputTargets
    const otp = inputs.map(input => input.value).join("")
    this.otpInputTarget.value = otp
  }

  startCountdown() {
    let secondsRemaining = this.expiresInValue

    if (secondsRemaining <= 0) {
      this.timerTarget.textContent = "Expired"
      this.countdownTarget.classList.add("expired")
      return
    }

    this.updateTimerDisplay(secondsRemaining)

    this.countdownInterval = setInterval(() => {
      secondsRemaining -= 1

      if (secondsRemaining <= 0) {
        clearInterval(this.countdownInterval)
        this.timerTarget.textContent = "Expired"
        this.countdownTarget.classList.add("expired")
        return
      }

      this.updateTimerDisplay(secondsRemaining)
    }, 1000)
  }

  updateTimerDisplay(seconds) {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    this.timerTarget.textContent = `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`
  }

  handleResend(event) {
    // Disable button and start cooldown
    const btn = this.resendBtnTarget
    btn.disabled = true
    btn.classList.add("disabled")

    let cooldownSeconds = 60
    this.cooldownTarget.textContent = `(${cooldownSeconds}s)`

    this.cooldownInterval = setInterval(() => {
      cooldownSeconds -= 1

      if (cooldownSeconds <= 0) {
        clearInterval(this.cooldownInterval)
        btn.disabled = false
        btn.classList.remove("disabled")
        this.cooldownTarget.textContent = ""
        return
      }

      this.cooldownTarget.textContent = `(${cooldownSeconds}s)`
    }, 1000)
  }
}
