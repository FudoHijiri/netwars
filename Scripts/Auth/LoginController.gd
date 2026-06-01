extends CanvasLayer

func _ready() -> void:
	$CenterContainer/VBoxContainer/LoginButton.pressed.connect(_on_login_pressed)
	$CenterContainer/VBoxContainer/RegisterButton.pressed.connect(_on_register_pressed)

func _on_login_pressed() -> void:
	var email = $CenterContainer/VBoxContainer/EmailInput.text
	var password = $CenterContainer/VBoxContainer/PasswordInput.text

	if email.is_empty() or password.is_empty():
		$CenterContainer/VBoxContainer/ErrorLabel.text = "Please fill in all fields"
		return

	$CenterContainer/VBoxContainer/ErrorLabel.text = "Logging in..."
	$CenterContainer/VBoxContainer/LoginButton.disabled = true

	Firebase.Auth.sign_in_with_email_and_password(email, password)
	await Firebase.Auth.login_succeeded

	var user = Firebase.Auth.current_user
	if user:
		MenuManager.start_game("offline")
	else:
		$CenterContainer/VBoxContainer/ErrorLabel.text = "Login failed"
		$CenterContainer/VBoxContainer/LoginButton.disabled = false

func _on_register_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Auth/Register.tscn")
