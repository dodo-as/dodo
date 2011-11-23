    CREATE FUNCTION accounts() RETURNS void AS $$
    DECLARE
         userRecord record;
    BEGIN
         FOR userRecord IN
              SELECT * FROM tb_user u ORDER BY u.user_id
         LOOP
              SELECT INTO user_property_id nextval('sq_user_property');

              -- user_property_id now has a value we can insert here
              INSERT INTO tb_user_property VALUES(
                        user_property_id ,
                        'user_id',
                        userRecord.id
              ) ;

              IF userRecord.email like 'user@domain.com' THEN

                        update userRecord set email = 'user@other-domain.com' where id = userRecord.id;

              ELSEIF userRecord.email is null THEN

                        update userRecord set active = false where id = userRecord.id;

              ELSE

                        RAISE NOTICE 'didn\'t update any record';

              END IF;


         END LOOP;
         RETURN;
    END;
    $$ LANGUAGE plpgsql;