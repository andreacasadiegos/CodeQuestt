<?php
/**
 * Validación de datos en el servidor.
 *
 * Uso:
 *   $v = new Validator();
 *   $v->required('email', $email, 'Escribe tu correo.')->email('email', $email);
 *   if ($v->fails()) Response::error('Datos inválidos', 422, $v->errors());
 *
 * Solo se guarda el primer error de cada campo.
 */

declare(strict_types=1);

final class Validator
{
    /** @var array<string, string> */
    private array $errors = [];

    public function required(string $field, string $value, string $message): self
    {
        if ($value === '') {
            $this->add($field, $message);
        }
        return $this;
    }

    public function email(string $field, string $value): self
    {
        if ($value !== '' && filter_var($value, FILTER_VALIDATE_EMAIL) === false) {
            $this->add($field, 'Escribe un correo electrónico válido.');
        }
        return $this;
    }

    public function length(string $field, string $value, int $min, int $max, string $label): self
    {
        $len = mb_strlen($value);
        if ($value !== '' && ($len < $min || $len > $max)) {
            $this->add($field, "$label debe tener entre $min y $max caracteres.");
        }
        return $this;
    }

    /** Nombre: letras (con tildes y ñ), espacios, apóstrofo y guion. */
    public function personName(string $field, string $value): self
    {
        if ($value !== '' && !preg_match("/^[\p{L}][\p{L} '\-]*$/u", $value)) {
            $this->add($field, 'El nombre solo puede contener letras y espacios.');
        }
        return $this;
    }

    /** Contraseña: al menos una letra y un número. */
    public function strongPassword(string $field, string $value): self
    {
        if ($value !== '' && (!preg_match('/\p{L}/u', $value) || !preg_match('/\d/', $value))) {
            $this->add($field, 'La contraseña debe incluir al menos una letra y un número.');
        }
        return $this;
    }

    public function matches(string $field, string $value, string $other, string $message): self
    {
        if ($value !== $other) {
            $this->add($field, $message);
        }
        return $this;
    }

    public function add(string $field, string $message): void
    {
        $this->errors[$field] ??= $message;
    }

    public function fails(): bool
    {
        return $this->errors !== [];
    }

    /** @return array<string, string> */
    public function errors(): array
    {
        return $this->errors;
    }
}
