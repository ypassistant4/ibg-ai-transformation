-- ============================================================================
-- Migration 009: разрешить новому пользователю пометить свой invite использованным
-- ============================================================================
-- Контекст: после успешного signUp пользователь залогинен, и из клиента
-- мы делаем UPDATE invites SET used_at = NOW(), used_by = auth.uid().
-- Существующая политика "Admins manage invites" из миграции 007 запрещает
-- UPDATE всем, кроме админов, — поэтому из клиента ничего не пишется.
--
-- Добавляем точечную RLS-политику: любой залогиненный пользователь может
-- пометить НЕиспользованное и НЕпросроченное приглашение использованным,
-- но только указав в used_by собственный auth.uid().
--
-- Race condition: два юзера могут одновременно потребить один и тот же invite.
-- Для PET это допустимо (поток ~50 человек). Для prod заменим на функцию
-- consume_invite() с SECURITY DEFINER и row-lock.
-- ============================================================================

-- Идемпотентно: можно запускать многократно без ошибки.
DROP POLICY IF EXISTS "Users mark unused invite as consumed" ON invites;

CREATE POLICY "Users mark unused invite as consumed"
    ON invites
    FOR UPDATE
    TO authenticated
    USING (used_at IS NULL AND expires_at > NOW())
    WITH CHECK (used_by = auth.uid() AND used_at IS NOT NULL);

-- ============================================================================
-- ПРОВЕРКА:
--
-- 1. Создать тестовый invite:
--    INSERT INTO invites (email, token) VALUES ('test@example.com', gen_random_uuid())
--    RETURNING *;
--
-- 2. URL для теста: http://localhost:3000/signup?invite=<token>
--
-- 3. После signUp проверить:
--    SELECT used_at, used_by FROM invites WHERE email = 'test@example.com';
--    → used_at должен быть заполнен, used_by = id нового пользователя
-- ============================================================================
