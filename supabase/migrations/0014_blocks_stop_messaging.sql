-- 0014_blocks_stop_messaging.sql
-- Task 7.1: Ein Block soll auch eine schon bestehende Konversation stumm
-- schalten, nicht nur (wie messages_insert es bisher schon tat, ueber
-- conversations_buyer_create in 0005_chat.sql) das Anlegen einer neuen
-- verhindern. Nutzervorgabe: Chat-Verlauf bleibt fuer beide Seiten lesbar --
-- nur das Senden neuer Nachrichten wird gesperrt, egal wer wen blockiert hat.
drop policy messages_insert on public.messages;

create policy messages_insert on public.messages
  for insert with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
        and not exists (
          select 1 from public.blocks b
          where (b.blocker_id = c.buyer_id and b.blocked_id = c.seller_id)
             or (b.blocker_id = c.seller_id and b.blocked_id = c.buyer_id)
        )
    )
  );
