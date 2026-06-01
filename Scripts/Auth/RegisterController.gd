extends CanvasLayer

func _ready() -> void:
	$CenterContainer/VBoxContainer/RegisterButton.pressed.connect(_on_register_pressed)
	$CenterContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_register_pressed() -> void:
	var email = $CenterContainer/VBoxContainer/EmailInput.text
	var password = $CenterContainer/VBoxContainer/PasswordInput.text
	var confirm_password = $CenterContainer/VBoxContainer/ConfirmPasswordInput.text
	var username = $CenterContainer/VBoxContainer/UsernameInput.text

	if email.is_empty() or password.is_empty() or confirm_password.is_empty() or username.is_empty():
		$CenterContainer/VBoxContainer/ErrorLabel.text = "Please fill in all fields"
		return

	if password != confirm_password:
		$CenterContainer/VBoxContainer/ErrorLabel.text = "Passwords do not match"
		return

	$CenterContainer/VBoxContainer/ErrorLabel.text = "Creating account..."
	$CenterContainer/VBoxContainer/RegisterButton.disabled = true

	Firebase.Auth.sign_up_with_email_and_password(email, password)
	await Firebase.Auth.signup_succeeded
	MenuManager.go_to_title_menu()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/TitleMenu.tscn")
