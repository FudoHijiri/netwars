extends Control

func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(_on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(_on_signup_succeeded)
	Firebase.Auth.login_failed.connect(_on_login_failed)
	Firebase.Auth.signup_failed.connect(_on_signup_failed)

func _on_back_pressed() -> void:
	MenuManager.go_to_title_menu()

func _on_login_pressed() -> void:
	var email = $CenterContainer/VBoxContainer/TabContainer/Login/EmailInput.text
	var password = $CenterContainer/VBoxContainer/TabContainer/Login/PasswordInput.text
	var error_label = $CenterContainer/VBoxContainer/TabContainer/Login/LoginErrorLabel

	if email.is_empty() or password.is_empty():
		error_label.text = "Please fill in all fields"
		return

	error_label.text = "Logging in..."
	$CenterContainer/VBoxContainer/TabContainer/Login/LoginButton.disabled = true

	Firebase.Auth.login_with_email_and_password(email, password)

func _on_register_pressed() -> void:
	var email = $CenterContainer/VBoxContainer/TabContainer/Register/RegEmailInput.text
	var password = $CenterContainer/VBoxContainer/TabContainer/Register/RegPasswordInput.text
	var confirm_password = $CenterContainer/VBoxContainer/TabContainer/Register/ConfirmPasswordInput.text
	var username = $CenterContainer/VBoxContainer/TabContainer/Register/UsernameInput.text
	var error_label = $CenterContainer/VBoxContainer/TabContainer/Register/RegErrorLabel

	if email.is_empty() or password.is_empty() or confirm_password.is_empty() or username.is_empty():
		error_label.text = "Please fill in all fields"
		return

	if password != confirm_password:
		error_label.text = "Passwords do not match"
		return

	error_label.text = "Creating account..."
	$CenterContainer/VBoxContainer/TabContainer/Register/RegisterButton.disabled = true

	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_login_succeeded(auth) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Welcome!"
	dialog.dialog_text = "Logged in as:\n%s" % auth.email
	get_tree().root.add_child(dialog)
	dialog.popup_centered_ratio(0.3)
	await dialog.confirmed
	dialog.queue_free()
	MenuManager.go_to_title_menu()

func _on_signup_succeeded(auth) -> void:
	var error_label = $CenterContainer/VBoxContainer/TabContainer/Register/RegErrorLabel
	error_label.text = "Account created! Returning to login..."
	await get_tree().create_timer(2.0).timeout
	MenuManager.go_to_title_menu()

func _on_login_failed(error_code: String, message: String) -> void:
	var error_label = $CenterContainer/VBoxContainer/TabContainer/Login/LoginErrorLabel
	error_label.text = "Login failed: %s" % message
	$CenterContainer/VBoxContainer/TabContainer/Login/LoginButton.disabled = false

func _on_signup_failed(error_code: String, message: String) -> void:
	var error_label = $CenterContainer/VBoxContainer/TabContainer/Register/RegErrorLabel
	error_label.text = "Sign up failed: %s" % message
	$CenterContainer/VBoxContainer/TabContainer/Register/RegisterButton.disabled = false
